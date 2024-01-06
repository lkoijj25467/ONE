%include 'boot.inc'

; 0x900
setup_page:
    mov ecx, 4096
    mov esi, 0
; 0x90c
.clear_page_dir:                                        ; 把1024个页目录项初始化成0
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir
; 0x918
.create_pde:                                            ; 初始化好了以后，创建页目录
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x1000                                     ; eax + 4KB                     PAGE_DIR_TABLE_POS + 4KB 是第零个页表的基地址，这个要存在第0个页目录项
    mov ebx, eax
    ; 0x924
    or eax, PG_US_U | PG_RW_W | PG_P                    ; User级  可读可写  存在         完善该页目录项，不但要有20位的基地址，还要有12位的其他信息
    mov dword [PAGE_DIR_TABLE_POS + 0], eax
    sub eax, 0x1000
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax               ; 0xc00 / 4 = 768  页目录表中第768项    从第768项之后为内核空间
    sub eax, 0x1000
    mov [PAGE_DIR_TABLE_POS + 4092], eax                ; 使最后一个页目录表项指向页目录表自己的地址
    mov ecx, 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
    mov [ebx + esi*4], edx
    add edx, 4096
    inc esi
    loop .create_pte                                    ; x256

    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000
    or eax, PG_US_U | PG_RW_W | PG_P
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254
    mov esi, 769
.create_kernel_pde:
    mov [ebx + esi*4], eax
    inc esi
    add eax, 0x1000
    loop .create_kernel_pde
    ret