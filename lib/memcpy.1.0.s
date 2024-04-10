; memcpy ;
; rdi - source
; rsi - source length
; rdx - destination
; r10 - destination length

section .text

memcpy:
    push rbx

    mov rbx, 0

memcpy_loop:
    cmp rbx, rsi
    je memcpy_end_loop
    cmp rbx, r10
    je memcpy_end_loop

    mov r11b, byte[rdi]
    mov byte[rdx], r11b
    inc rdi
    inc rdx
    inc rbx
    jmp memcpy_loop
memcpy_end_loop:

    pop rbx
    ret