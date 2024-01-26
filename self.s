%include "baseData.1.0.s"

section .data
	input_max equ 32                ; Declare constant size, used to reserve variables

	s0 db "Test test help",NL,NULL  ; Declare byte list with initial contents
	s1 db "Enter name: ",NULL
	s2 db "Enter something you like: ",NULL
	s3 db "Enter something you HATE: ",NULL
	s4 db "Hello my name is ",NULL
	s5 db " and I like ",NULL
	s6 db "! But I HATE ",NULL
	s7 db " >:( ",NL,NULL
	;newLine db NL                   ; Define a variable that is just the new line byte. As we can't point to a constant (NL).
section .bss 
	;input_char resb 1               ; Reserve one byte of unset data for character input
	in1 resb input_max              ; Reserve 3 strings with length "input_max" to add to with character input
	in2 resb input_max
	in3 resb input_max

section .text
global _start
_start:                             ; Main code
	mov rdi, s0                     ; Point rdi to the address of "s0", and call "print" which uses rdi
	call print

	mov rdi, s1                     ; Point rdi to s1 and call print
	call print
	mov rax, input_max              ; Point rsi to input max (which holds input data length)
	mov rdi, in1                    ; Point rdi to in1 (which holds input data location)
	call input                      ; Call input

	mov rdi, s2
	call print
	mov rax, input_max
	mov rdi, in2
	call input

	mov rdi, s3
	call print
	mov rax, input_max
	mov rdi, in3
	call input

	mov rdi, s4
	call print
	mov rdi, in1
	call print
	mov rdi, s5
	call print
	mov rdi, in2
	call print
	mov rdi, s6
	call print
	mov rdi, in3
	call print
	mov rdi, s7
	call print
	; call println                    ; Print just a new line character

	mov rax, SYS_exit               ; Exit with return value 0
	mov rdi, 0
	syscall

%include "print.1.1.s"
%include "input.1.0.s"