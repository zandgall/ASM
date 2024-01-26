; malloc ;
; rdi - size ;
; output rax ;
; - Allocates private anonymous read/write memory with the given size

%ifndef MALLOC
%define MALLOC
%include "sysdef.1.1.s"
section .text
malloc:
	mov rax, SYS_mmap						; Make a system call to mmap
	mov rsi, rdi							; Move the size to rsi
	mov rdi, 0								; Let the system decide the direction
	mov rdx, PROT_READ | PROT_WRITE			; Read / writable
	mov r8, -1								; To memory
	mov r9, 0								; With no offset
	mov r10, MAP_PRIVATE | MAP_ANONYMOUS	; Private and anonymous
	syscall
	ret
%endif