; Stack 'class'
;   *begin, *end, u64 available, u64 element_size
; stack_new(rdi: element_size) => rax: pointer to stack 
;	~ Creates a stack with the given element size. (output points to the stack class, not the stack data itself)

; stack_get(rax: *stack, rdi: index) => rax: pointer to element
;	~ Grabs the address of the element at the given index

; stack_push(rax: *stack, rdi: *element)
;	~ Puts the contents of the given element address into the stack. Reads stack->element_size bytes at element

; stack_pop(rax: *stack) => rax: element popped if element_size <= 8
;	~ Pops the last element off the stack, and if its size is 8 or less, put its value in rax

; TODO BOARD ;
; - Implement error checking
; - Max stack allocation increase/decrease

%ifndef STACK
%define STACK
%include "mem.1.0.s"

section .text
;~~~~~~~~~~~;
; STACK NEW ;
;~~~~~~~~~~~;
; Input:
;	rdi - element_size
; Output:
;	rax - *stack
stack_new:
	push r12
	push rdi				; save 'element_size'
	call malloc				; allocate one element's size
	mov r12, rax			; save the location in r12

	mov rdi, 32				; allocate 32 bytes, the size of the stack class structure (see top of file)
	call malloc


	pop rdi					; restore 'element_size'
	mov qword[rax], r12		; set the first 8 bytes to the address of the currently 1-element allocated stack
	add rax, 8				; move to the next 8 byte element (*end)
	mov qword[rax], r12		; set the next 8 bytes to the address of the currently 1-element allocated stack, (0 elements actually added)
	add rax, 8				; move to the next 8 byte element (available)
	mov qword[rax], 1		; set it to 1 element available
	add rax, 8				; mov to the next 8 byte element (element_size)
	mov qword[rax], rdi		; set it to element_size
	sub rax, 24				; point rax back to the beginning of the class, and return
	pop r12
	ret

;~~~~~~~~~~~;
; STACK GET ;
;~~~~~~~~~~~;
; Input:
;	rax - *stack
;	rdi - index
; Output:
;	rax - *element
stack_get:
	mov r8, qword[rax]		; r8 holds *begin
	add rax, 8
	mov r9, qword[rax]		; r9 holds *end
	add rax, 16
	mov r10, qword[rax]		; r10 holds element_size
	push rax
	mov rax, rdi
	mul r10					; multiply index by rdi
	mov rdi, rax
	pop rax
	add r8, rdi				; move along the stack using index * element_size

	cmp r8, r9				; compare selected element to end of stack
	jae stack_get_error		; if selected element is above or equal to end of stack, index out of bounds error

	mov rax, r8				; set rax to r8 (pointer to element)
	ret

; TODO IMPLEMENT ERRORS
stack_get_error:
	sub rax, 24				; just point back to original
	ret

;~~~~~~~~~~~~;
; STACK PUSH ;
;~~~~~~~~~~~~;
; Input:
;	rax - *stack
;	rdi - *element
stack_push:
	push r12
	push r13
	push r14
	push r15
	mov r12, qword[rax]		; r12 = *start
	add rax, 8
	mov r13, qword[rax]		; r13 = *end
	sub r13, r12			; r13 = size of stack (in bytes)
	mov r12, qword[rax]		; r12 = *end
	add rax, 8
	mov r14, qword[rax]		; r14 = available (in elements)
	add rax, 8
	mov r15, qword[rax]		; r15 = element_size
	push rax
	mov rax, r14
	mul r15					; rax = available (in bytes)
	mov r14, rax			; r14 = available (in bytes)
	pop rax
	cmp r13, r14			; compare size of stack to available
	jb stack_push_skip_grow	; if the size of stack is below available, don't realloc
	; call stack_realloc_grow	; otherwise do realloc
	push rdi
	push rbx
	mov rbx, rax			; set rbx to rax

	mov rdi, r14
	shl rdi, 1
	call malloc				; allocate twice as much space

	; TODO IMPLEMENT ERRORS
	cmp rax, -1
	je stack_push_error

	sub rbx, 24				; point rbx to beginning of stack class
	mov rdi, qword [rbx]
	mov rsi, r14
	mov rdx, rax
	mov r10, r14
	call mcopy				; copy stack over to new allocated space

	mov rdi, qword [rbx]	; rdi = original *start
	mov qword [rbx], rax	; *start = new space
	add rbx, 8				; rbx->end
	mov qword [rbx], rax	; *end = new space
	add qword [rbx], r13	; *end += size of stack (in bytes)
	mov r12, qword [rbx]	; r12 = *end
	add rbx, 8
	shl qword [rbx], 1		; double available
	add rbx, 8				; rbx -24 + 8 + 8 + 8 Makes rbx unchanged

	mov rsi, r14
	call munalloc			; unallocate previous stack space

	mov rax, rbx
	pop rbx
	pop rdi

stack_push_skip_grow:		;

	;r12=*end, rdi = *element, r15 = element_size
	mov rsi, r15
	mov rdx, r12
	mov r10, r15
	call mcopy				; copy element_size bytes from rdi (*element) to end of stack
	
	sub rax, 16				; point rax to *end
	add qword[rax], r15		; increment *end of stack by element_size

	pop r15
	pop r14
	pop r13
	pop r12
	ret
stack_push_error:
	pop rdi
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	ret

;~~~~~~~~~~~;
; STACK POP ;
;~~~~~~~~~~~;
; Input:
;	rax - *stack
; Output:
;	rax - element (if element_size<=8)
stack_pop:
	push r12
	push r13
	push r14
	push r15
	mov r12, qword[rax]		; r12 = *start
	add rax, 8
	mov r13, qword[rax]		; r13 = *end
	cmp r12, r13
	je stack_pop_ret		; If the end and the start are the same, (size==0) return
	sub r13, r12			; r13 = size of stack (in bytes)
	mov r12, qword[rax]		; r12 = *end
	add rax, 8
	mov r14, qword[rax]		; r14 = available (in elements)
	add rax, 8
	cmp r14, 1				; If the available num of elements is just 1, skip shrink (see next jmp inst)
	mov r15, qword[rax]		; r15 = element_size
	push rax
	mov rax, r14
	mul r15					; rax = available (in bytes)
	mov r14, rax			; r14 = available (in bytes)
	pop rax
	je stack_pop_skip_shrink; 
	mov r8, r13
	shl r8, 2
	cmp r8, r14				; compare (size of stack) << 2 to available
	ja stack_pop_skip_shrink; if size of stack is not 2 factors smaller than available, dont shrink stack

	push rdi
	push rbx
	mov rbx, rax			; set rbx to rax

	mov rdi, r14
	shr rdi, 1
	call malloc				; allocate half as much space

	; TODO IMPLEMENT ERRORS
	cmp rax, -1
	je stack_push_error

	sub rbx, 24				; point rbx to beginning of stack class
	mov rdi, qword [rbx]
	mov rsi, r14
	shr rsi, 1
	mov rdx, rax
	mov r10, rsi
	call mcopy				; copy stack over to new allocated space

	mov rdi, qword [rbx]	; rdi = original *start
	mov qword [rbx], rax	; *start = new space
	add rbx, 8				; rbx->end
	mov qword [rbx], rax	; *end = new space
	add qword [rbx], r13	; *end += size of stack (in bytes)
	mov r12, qword [rbx]	; r12 = *end
	add rbx, 8
	shr qword [rbx], 1		; half available
	add rbx, 8				; rbx -24 + 8 + 8 + 8 Makes rbx unchanged

	mov rsi, r14
	call munalloc			; unallocate previous stack space

	mov rax, rbx
	pop rbx
	pop rdi

stack_pop_skip_shrink:
	; r12 = end, r15 = element_size, rax -> element_size
	sub rax, 16 			; rax -> end
	cmp r15, 8
	mov r12, rax			; r12 -> end
	ja stack_pop_no_ret_val ; if element_size > 8, don't return a value
	mov r13, qword[rax]
	mov r14, qword[rax]
	sub r14, r15
	; add r13, r15
	xor rax, rax
stack_pop_ret_val_loop:
	dec r13
	shl rax, 1
	add al, byte [r13]
	cmp r13, r14
	ja stack_pop_ret_val_loop
stack_pop_no_ret_val:
	sub qword[r12], r15
stack_pop_ret:
	pop r15
	pop r14
	pop r13
	pop r12
	ret
	
%endif