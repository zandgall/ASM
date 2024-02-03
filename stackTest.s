%include "stdio.1.0.s"
%include "stack.1.0.s"

section .data
	input_len equ 16
	input_msg db "Add to stack: ",NULL
	stack_msg db "Contents of stack:",NL,NULL
	quote db '"'
section .bss
	stack1 resq 1
	instr resb input_len

section .text
global _start
_start:
	mov rdi, 1
	call stack_new						; create stack with 1-size elements
	mov qword [stack1], rax				; and set it to stack1
	
	mov rdi, input_msg
	call print
	
	mov rdi, instr
	mov rsi, input_len
	call input

	mov r13, rax
	mov r12, instr
	xor rbx, rbx
add_to_stack_loop:
	mov rax, qword [stack1]
	mov rdi, r12
	call stack_push
	inc rbx
	inc r12
	cmp rbx, r13
	jne add_to_stack_loop

	mov rdi, stack_msg
	call print
	mov rdi, quote
	mov rsi, 1
	call printn


	xor rbx, rbx
print_stack_loop:
	mov rax, qword [stack1]
	mov rdi, rbx
	call stack_get
	mov rdi, rax
	mov rsi, 1
	call printn
	inc rbx
	cmp rbx, r11
	jne print_stack_loop

	mov rdi, quote
	mov rsi, 1
	call printn
	call println

	mov rdi, quote
	mov rsi, 1
	call printn
pop_stack_loop:
	dec rbx
	mov rax, qword [stack1]
	mov rdi, rbx
	call stack_get
	mov rdi, rax
	mov rsi, 1
	call printn

	mov rax, qword [stack1]
	call stack_pop

	cmp rbx, 0
	jne print_stack_loop

	mov rax, SYS_exit
	mov rdi, 0
	syscall