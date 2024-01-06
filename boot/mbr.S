%include "boot.inc"
SECTION MBR vstart=0x7c00

    mov ax, cs
    mov ds, ax
    mov fs, ax
    mov ss, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax                              ;gs = 0xb800
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0
    mov dx, 0x184f
    int 0x10

    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0xA4

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4
    
    mov byte [gs:0x04], 'M'
    mov byte [gs:0x05], 0xA4

    mov byte [gs:0x05], 'B'
    mov byte [gs:0x06], 0xA4

    mov byte [gs:0x07], 'R'
    mov byte [gs:0x08], 0xA4
    
    ;rd_disk_m_16三个参数分别为eax: 扇区号   bx: 物理地址    cx：一次操作的扇区数
    mov eax, LOADER_START_SECTOR                ;eax存放了扇区号
    mov bx, LOADER_BASE_ADDR                
    mov cx, 4                           
    call rd_disk_m_16                           ;读取磁盘信息写道LOADER_BASE_ADDR的物理地址上，并跳转
    jmp LOADER_BASE_ADDR

rd_disk_m_16:                                   ;rd_disk_m_16三个参数分别为eax: 扇区号   bx: 物理地址    cx：一次操作的扇区数
    mov esi, eax                                ;保护eax寄存器
    mov di, cx
    mov dx, 0x1f2
    mov al, cl                                  ;al = 0x01
    out dx, al                                  ;将0x01写入到0x1f2端口中，表示一次操作一个扇区
    mov eax, esi

    mov dx, 0x1f3                               ;eax: 0x_654 32[10]
    out dx, al

    mov cl, 8                                   ;eax: 0x___6 54[32]
    shr eax, cl
    mov dx, 0x1f4
    out dx, al

    shr eax, cl                                 ;eax: 0x____ _6[54]
    mov dx, 0x1f5
    out dx, al

    shr eax, cl                                 ;eax: 0x____ __[_6]    0x_6 bin> xxxx
    and al, 0x0f
    or al, 0xe0                                 ;al:  1110 xxxx
    mov dx, 0x1f6               
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    .not_ready:
        nop
        in al, dx                               ;此时dx = 0x1f7 标志
        and al, 0x80                            ;0x88 bin> 1000 1000    如果标志的第7位和第3位都为0，则继续；否则，跳转回去
        jnz .not_ready

        mov ax, di                              ;di = 0x04
        mov dx, 256                             
        mul dx                                  ;eax = eax*dx   ax = ax*dx = 1*256 = 156
        mov cx, ax                              ;ax = di = 0x01     cx = 256

        mov dx, 0x1f0                           ;开始读取数据端口
    .go_on_read:
        in ax, dx                               ;将数据端口中缓存的16位数据读入ax寄存器
        mov [bx], ax                            ;bx是rd_disk_m16的参数，目的物理地址
        add bx, 2                               ;因为数据是16位的，占两字节，所以bx指针自加2
        loop .go_on_read                        ;循环次数在cx中，256
        ret


    times 510-($-$$) db 0
    ;dw 0x55aa
    db 0x55, 0xaa
