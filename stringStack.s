%include "baseData.1.0.s"
%include "print.1.3.s"
%include "input.1.1.s"
%include "memcpy.1.0.s"

section .data
    PROT_NONE equ 0x0
    PROT_READ equ 0x1
    PROT_WRITE equ 0x2
    PROT_EXECUTE equ 0x4
    MAP_PRIVATE equ 0x2
    MAP_ANONYMOUS equ 0x20
    ; PROT_READWRITE equ 3
    
    MAP_FAILED equ -1
    success_msg db "Woo! It works :3",NL,NULL
    failed_msg db "Failed to allocate :c",NL,NULL
    quote db '"',NULL
    menu_msg db "STRING STACK",NL,"(p)rint",NL,"p(u)sh",NL,"p(o)p",NL,"(e)xit",NL,"> ",NULL
    menu_missed db "Invalid choice! Choose again",NL,NULL
section .bss
    stack_start: resq 1
    stack_end: resq 1
    stack_size: resq 1
    stack_available: resd 1

    menu_sel: resb 2

section .text
global _start
_start:
    mov dword [stack_size], 0
    mov dword [stack_available], 8
    mov rax, SYS_mmap
    mov rdi, 0
    mov rsi, stack_available
    mov rdx, PROT_READ | PROT_WRITE
    mov r8, -1
    mov r9, 0
    mov r10, MAP_PRIVATE | MAP_ANONYMOUS
    syscall

    cmp rax, -1
    jne stack_success
stack_failed:
    mov rdi, failed_msg
    call print
    jmp stack_exit
stack_success:

    mov qword [stack_start], rax
    mov qword [stack_end], rax
    add qword [stack_end], 8

    mov rdi, success_msg
    call print
stack_end_print:

stack_loop:
    mov rdi, menu_msg
    call print

    mov rdi, menu_sel
    mov rsi, 2
    call input

    cmp byte [menu_sel], 'p'
    je stack_print
    cmp byte [menu_sel], 'u'
    je stack_push
    cmp byte [menu_sel], 'o'
    je stack_pop
    cmp byte [menu_sel], 'e'
    je stack_exit
    
    mov rdi, menu_missed
    call print
    jmp stack_loop

stack_print:
    mov rdi, quote
    call print
    mov rdi, stack_start
    mov rsi, qword [stack_size]
    call printn
    mov rdi, quote
    call print
    call println

    jmp stack_loop
stack_push:
    cmp qword [stack_size], qword[stack_available]
    jae stack_realloc
    jmp stack_realloc_end
stack_realloc:
    ; shl qword [stack_available], 1
    mov rax, SYS_mmap
    mov rdi, 0
    mov rsi, stack_available
    shl rsi, 1 ; Double space
    mov rdx, PROT_READ | PROT_WRITE
    mov r8, -1
    mov r9, 0
    mov r10, MAP_PRIVATE | MAP_ANONYMOUS
    syscall

    mov rdi, stack_start
    mov rsi, stack_available
    mov rdx, rax
    shl qword [stack_available], 1
    mov r10, stack_available
    call memcpy

    shl qword [stack_available], 1

    cmp rax -1
    je stack_failed

    mov qword [stack_start], rax
    mov qword [stack_end], rax
    inc stack_end, qword [stack_size]

stack_realloc_end:
    mov rdi, menu_sel
    mov rsi, 2
    call input

    mov r8, 

    jmp stack_loop
stack_pop:

    jmp stack_loop
stack_exit:
    mov rax, SYS_exit
    mov rdi, 0
    syscall
