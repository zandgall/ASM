; mcopy ;
; rdi - source
; rsi - source length
; rdx - destination
; r10 - destination length

section .text

mcopy:
	push rbx				; Save rbx
	mov rbx, 0				; Set to 0 - We will use this to count
mcopy_loop:
	cmp rbx, rsi			; Compare rbx to both src length and dest length
	jae mcopy_end_loop		; If it's greater or equal to either, end the loop
	cmp rbx, r10
	jae mcopy_end_loop

	mov r11b, byte[rdi]		; Move the byte that src points to, to r11b
	mov byte[rdx], r11b		; Move r11b to the byte that dest points to
	inc rdi					; Increment the src pointer, dest pointer, and length counter
	inc rdx
	inc rbx
	jmp mcopy_loop
mcopy_end_loop:
	pop rbx					; Restore rbx
	ret