section .text
global _start
_start:
	xor al, al
	dec al

	mov al, 127
	inc al

	mov al, -128
	dec al

	mov al, 255
	inc al

	mov rax, 60
	mov rdi, 0
	syscall	