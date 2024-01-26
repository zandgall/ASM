
section .text

memcpy:
    push rbx

    mov rbx, 0
    mov r8, rsi
    mov r9, rdx

memcpy_loop:
    cmp rbx, rsi
    je memcpy_end_loop
    cmp rbx, r10
    je memcpy_end_loop

    mov byte[r8], byte[r9]
    inc r8
    inc r9
    inc rbx

memcpy_end_loop:

    pop rbx
    ret