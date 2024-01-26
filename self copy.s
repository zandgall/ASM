section .data
    NL equ 10
    NULL equ 0
    true equ 1
    false equ 0
    TRUE equ 1
    FALSE equ 0

    STDIN equ 0
    STDOUT equ 1
    STDERR equ 2

    SYS_read equ 0
    SYS_write equ 1
    SYS_open equ 2
    SYS_close equ 3
    SYS_form equ 57
    SYS_exit equ 60
    SYS_creat equ 85
    SYS_time equ 201

; section .data
    input_max equ 255

    s0 db "Test test help",NL,NULL
    s1 db "Enter something: ",NULL
    s2 db "You Entered: ",NULL
    newLine db NL
section .bss 
    input_char resb 1
    input_string resb input_max
    

section .text
global _start
_start:
    mov rdi, s0
    call print

    mov rdi, s1
    call print
    call input
    mov rdi, s2
    call print
    mov rdi, input_string
    call print
    call println

    mov rax, 60
    mov rdi, 0
    syscall

print:
    push rbx

    mov rbx, rdi
    mov rdx, 0
print_countLoop:
    cmp byte [rbx],NULL
    je print_countLoopEnd
    inc rdx
    inc rbx
    jmp print_countLoop
print_countLoopEnd:
    cmp rdx, 0
    je print_done

    mov rax, SYS_write
    mov rsi, rdi
    mov rdi, STDOUT

    syscall
print_done:
    pop rbx
    ret

println:
    mov rax, SYS_write
    mov rdx, 1
    mov rsi, newLine
    mov rdi, STDOUT

    syscall
    ret

input:
    push rbx

    mov rbx, input_string
    mov r12, 0
input_characterLoop:
    mov rax, SYS_read
    mov rdi, STDIN
    lea rsi, byte [input_char]
    mov rdx, 1
    syscall

    mov al, byte [input_char]
    cmp al, NL
    je input_characterLoopDone
    
    inc r12
    cmp r12, input_max
    jae input_characterLoop

    mov byte [rbx], al
    inc rbx

    jmp input_characterLoop
input_characterLoopDone:
    mov byte [rbx], NULL

    ; mov rdi, input_string
    ; call print
    pop rbx
    ret