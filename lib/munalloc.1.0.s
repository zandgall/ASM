; munalloc ;
; rdi - location
; rsi - size
; - Frees rsi bytes of memory at location rdi

%ifndef MUNALLOC
%define MUNALLOC
%include "sysdef.1.1.s"
section .text
munalloc:
    mov rax, SYS_munmap ; Make a system call to munmap, rdi and rsi already contain location and size
    syscall
    ret
%endif