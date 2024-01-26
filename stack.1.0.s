; Stack 'class'
;   *begin, *end, u64 available, u64 element_size
; stack_new(rdi: element_size) => rax: pointer to stack (NOTICE: NOT POINTER TO WHAT'S CONTAINED IN THE STACK, BUT TO THE STACK CLASS DEFINED ABOVE)
%ifndef STACK
%define STACK

section .text
stack_new:
	push rdi

	mov rdi, 32
	

	; pop rdi

%endif