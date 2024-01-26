%include "sysdef.1.1.s"
%include "print.1.4.s"
%include "input.1.2.s"
%include "mem.1.0.s"

section .data
	success_msg db "Woo! It works :3",NL,NULL
	failed_msg db "Failed to allocate :c",NL,NULL
	quote db '"',NULL
	menu_msg db "~~~~String Stack~~~~",NL,"(p)rint",NL,"p(u)sh",NL,"p(o)p",NL,"(e)xit",NL,"> ",NULL
	menu_missed db "Invalid choice! Choose again",NL,NULL
	pop_msg db "Popped: ",'"',NULL
	empty_msg db "Stack is empty!",NL,NULL
section .bss
	stack_start: resq 1
	stack_end: resq 1
	stack_available: resq 1

	menu_sel: resb 2

section .text
global _start
_start:
	mov qword [stack_available], 8		; Set stack_available and allocate 8 bytes
	mov rdi, qword [stack_available]
	call malloc

	cmp rax, -1							; Check if the allocation failed, 
	jne stack_success					; If it *didn't* fail, run success
stack_failed:							
	mov rdi, failed_msg					; Otherwise print fail message and exit
	call print
	mov rax, SYS_exit					; Exit with error
	mov rdi, -1	
	syscall
	; jmp stack_exit
stack_success:
	mov qword [stack_start], rax		; Set stack_start and stack_end to the beginning of the allocated area
	mov qword [stack_end], rax

	mov rdi, success_msg				; Print success message
	call print

	; MAIN LOOP ;
stack_loop:
	mov rdi, menu_msg					; Print the menu message
	call print

	mov rdi, menu_sel					; Take input
	mov rsi, 2
	call input

	cmp byte [menu_sel], 'p'			; Switch on menu_sel, p prints, u pushes, o pops, and e exits
	je stack_print
	cmp byte [menu_sel], 'u'
	je stack_push
	cmp byte [menu_sel], 'o'
	je stack_pop
	cmp byte [menu_sel], 'e'
	je stack_exit
	
	mov rdi, menu_missed				; Default case, print menu missed message and loop
	call print
	jmp stack_loop

	; PRINT STACK ;
stack_print:
	mov rdi, quote						; Print a quote,
	call print
	mov rdi, qword [stack_start]		; Measure stack size,
	mov rsi, qword [stack_end]
	sub rsi, rdi
	call printn							; And print that many elements starting at stack_start
	mov rdi, quote						; print another quote and a new line
	call print
	call println

	jmp stack_loop


	; PUSH TO STACK ;
stack_push:
	mov r8, qword[stack_available]		
	mov r9, qword[stack_end]			; Measure stack size
	sub r9, qword[stack_start]
	cmp r9, r8							; Compare stack size to stack_available
	jae stack_grow						; If stack size >= stack_available, reserve more space
	jmp stack_grow_end					; Otherwise skip to push
	; RESERVE MORE SPACE ; 
stack_grow:
	mov rdi, qword [stack_available]
	shl rdi, 1 							; Double how much space we're allocating
	call malloc

	cmp rax, -1							; If allocation failed, do stack failed routine
	je stack_failed

	push qword [stack_start]			; Save the current stack start

	mov rdi, qword [stack_start]		; Set stack origin
	mov rsi, qword [stack_available]	; and current size,
	mov rdx, rax						; Destination,
	mov r10, qword [stack_available]	; Destination size
	shl r10, 1							; Doubled
	call mcopy							; Do copy

	mov r9, qword[stack_end]			; Get stack length
	sub r9, qword[stack_start]
	mov qword [stack_start], rax		; Point stack_start to new allocated section
	add rax, r9							; Add size to rax,
	mov qword [stack_end], rax			; And point stack_end to the new rax

	pop rdi 							; Put the old stack location in rdi
	mov rsi, qword [stack_available]	; The old stack length,
	call munalloc						; And free old stack memory

	shl qword [stack_available], 1		; Double the stack_available variable

	; Main push segment ;
stack_grow_end:
	mov rdi, menu_sel					; Ask for a character to add to the stack
	mov rsi, 2
	call input

	mov r8, qword [stack_end]			; r8 = end of stack
	mov r9b, byte [menu_sel]			; Get the character menu_sel is pointing to, and put it in r9b
	mov byte [r8], r9b					; Then put it in the byte r8 (end of stack) is pointing to
	inc r8								; Increment r8 (end of stack pointer)
	mov qword [stack_end], r8			; And set stack_end back to r8
	jmp stack_loop						; Back to main loop

	; POP THE STACK ; 
stack_pop:
	mov r9, qword[stack_end]
	sub r9, qword[stack_start]
	cmp r9, 0							; If there's nothing in the stack,
	je stack_empty_err					; Jump to empty stack error
	cmp qword[stack_available], 8		; Minimum stack size is 8
	jbe stack_shrink_end				; Jump past shrinking if available is 8 or less
	mov r8, qword[stack_available]
	shr r8, 2 							; If stack size is 2 factors less than available, (i.e. stack_available = 32, size = 8)
	cmp r9, r8
	jbe stack_shrink 					; If stack size 2 factors less or lower, shrink available space
	jmp stack_shrink_end				; Otherwise do main pop sequence
	; Shrink stack ;
stack_shrink:
	mov rdi, qword[stack_available]		; Get the current size,
	shr rdi, 1							; Half it,
	call malloc							; And allocate that much space

	cmp rax, -1							; If it failed, run failed to allocate sequence
	je stack_failed

	push qword [stack_start]			; Save current stack location

	mov rdi, qword [stack_start]		; Point rdi to stack_start
	mov rsi, qword [stack_available]	; Give it the current size
	mov rdx, rax						; Give it the new stack location
	mov r10, qword [stack_available]	; And size
	shr r10, 1  						; (Half how much space is available)
	call mcopy							; then mcopy

	mov qword [stack_start], rax		; Point stack_start to the new location
	add rax, qword[stack_available]		; Add previous size to new location,
	mov qword [stack_end], rax			; And set stack end to that

	pop rdi 							; Put the old stack location in rdi
	mov rsi, qword [stack_available]	; The old size in rsi
	call munalloc						; And free up the old stack memory

	shr qword [stack_available], 1		; And update the stack_available variable
	; Main pop sequence ;
stack_shrink_end:

	mov rdi, pop_msg					; print out Popped: "
	call print

	dec qword[stack_end]				; Decrement the stack end pointer
	mov r8, qword[stack_end]			; Get the pointer that it points to
	mov r9b, byte[r8]					; Get the byte that points to
	mov rdi, menu_sel					; Put menu_sel in rdi
	mov byte[rdi], r9b					; And set it's first char to the character just popped 
	mov rsi, 1							; Set the size to 1
	call printn							; Print that character
	mov rdi, quote						; Then print an end quote, and new line
	call println
	jmp stack_loop						; Back to main loop
	; Runs if we try to pop an empty stack ;
stack_empty_err:
	mov rdi, empty_msg					; Prints empty stack message, then goes back to main loop
	call print
	jmp stack_loop

	; EXIT PROGRAM ;
stack_exit:
	mov rax, SYS_exit					; Exit with no error
	mov rdi, 0
	syscall
