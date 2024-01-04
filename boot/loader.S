kernel_init:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    mov dx, [KERNEL_BIN_ADDR + 42]
    mov ebx, [KERNEL_BIN_ADDR + 28]
    
    add ebx, KERNEL_BIN_ADDR
    mov cx, [KERNEL_BIN_ADDR + 44]

.each_segment
    cmp byte [ebx + 0], PT_NULL
    je .PT_NULL

    push dword [dbx + 16]
    mov eax, [ebx + 4]
    add eax, KERNEL_BIN_ADDR

    push eax
    push dword [ebx + 8]

    call mem_cpy
    add esp, 12
.PT_NULL
    add ebx, edx
    loop .each_segment
    ret
mem_cpy:
    cld
    push ebp                                    ;ebp[0] ebp[1] ebp[2] ebp[3] 
                                                ;                     ^esp
    mov ebp, esp                                ;ebp[0] ebp[1] ebp[2] ebp[3] ecx[0] ecx[1] ecx[2] ecx[3]
                                                ;                     ^ebp                        ^esp
    push ecx

    mov edi, [ebp + 8]
    mov esi, [ebp + 12]
    mov ecx, [ebp + 16]
    rep movsb

    pop ecx
    pop ebp
    ret