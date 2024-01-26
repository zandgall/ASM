%include "baseData.1.0.s"
%include "print.1.3.s"
%include "input.1.1.s"
%include "memcpy.1.0.s"

section .data
    content_len equ 16
    half_len equ 8
    original_msg db "You entered: ",NULL
    copied_msg db "We copied: ",NULL
    half_msg db "Copied half: ",NULL

section .bss
    original resb content_len
    copied resb content_len
    half resb content_len

section .text
global _start
_start:
    mov rdi, original
    mov rsi, content_len
    call input

    mov rdi, original_msg
    call print
    mov rdi, original
    call print
    
    mov rdi, original
    mov rsi, content_len
    mov rdx, copied
    mov r10, content_len
    call memcpy

    mov rdi, original
    mov rsi, half_len
    mov rdx, half
    mov r10, content_len
    call memcpy