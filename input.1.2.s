; INPUT FUNCTION ;
; output string - rdi ;
; output size - rsi ;

%ifndef INPUT
%define INPUT
%include "sysdef.1.1.s"
section .bss
    input_char resb 1
section .text

input:
	push rbx						; Preserve rbx, r12, and r13
	push r12
	push r13

	mov rbx, rdi					; Point rbx to the output string location
	mov r12, 0						; Set r12 to 0 [input length]
	mov r13, rsi					; Set r13 to rsi [max input length/output size]

input_characterLoop:				; Mark input loop
	mov rax, SYS_read				;	Make a syscall that reads 1 character, and puts it in input_char
	mov rdi, STDIN
	lea rsi, byte [input_char]
	mov rdx, 1
	syscall

	cmp byte [input_char], NL 		; If the input if a new line character, stop reading
	je input_characterLoopDone
	
	inc r12							; Increment the input length counter
	cmp r12, r13					; Compare the input length to the max length/output size
	jae input_characterLoop			; If r12 >= (above/equal) r13 then loop again without writing to the buffer

	mov al, byte [input_char]		; Read input_char and put it in al
	mov byte [rbx], al				; put al into the byte location that rbx is pointing to
	inc rbx							; increment rbx [point to next character in output string]

	jmp input_characterLoop			; loop again
input_characterLoopDone:

	mov byte [rbx], NULL			; Add a null character to the end of the output string

	pop r13							; Reset r13, r12, and rbx to what they were before this routine
	pop r12
	pop rbx
	ret								; Return
%endif