%include "../lib/stdio.1.0.s"
%include "../lib/stack.1.0.s"

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
	
	mov rdi, input_msg					; input string to copy to the stack
		call print
	mov rdi, instr
	mov rsi, input_len
		call input

	mov r13, rax						; r13 = input length
	mov r12, instr 						; r12 -> input string
	xor rbx, rbx						; rbx = 0
add_to_stack_loop:
	mov rax, qword [stack1]				; add input string[rbx] to stack1
	mov rdi, r12
	call stack_push
	inc rbx
	inc r12
	cmp rbx, r13
	jne add_to_stack_loop				; loop until rbx = input length


	mov rdi, stack_msg					; print "Contents of stack: " message
	call print
	mov rdi, quote
	mov rsi, 1
	call println

	xor rbx, rbx						; rbx = 0, r13 = input length
print_stack_loop:
	mov rax, qword [stack1]
	mov rdi, rbx
	call stack_get						; get stack1[rbx]
	mov rdi, rax
	mov rsi, 1
	call println						; print it
	inc rbx
	cmp rbx, r13
	jne print_stack_loop				; loop until rbx = input length

	mov rdi, quote						; print " + \n
	mov rsi, 1
	call printn
	call println

	mov rdi, quote
	mov rsi, 1
	call printn
pop_stack_loop:							; rbx = input length
	mov rax, qword [stack1]				; pop the end of the stack
	call stack_pop
	mov rdi, rax						; print out the rax return value
	call printc

	dec rbx
	cmp rbx, 0
	jne pop_stack_loop					; until rbx = 0

	mov rdi, quote
	mov rsi, 1
	call printn
	call println						; final quote,

	mov rax, SYS_exit					; then exit
	mov rdi, 0
	syscall
