;~~~~CONTENTS~~~~~~
; print(rdi: *string)
;	~ Prints the string pointed to by rdi, up until a NULL / 0x00 is reached
; printn(rdi: *string, rsi: length)
;	~ Prints the string pointed to by rdi, printing rsi chars
; println()
;	~ Prints just a newline (\n) character
; printc(rdi: char)
;	~ Prints a single char
; 

%ifndef PRINT
%define PRINT
%include "sysdef.1.1.s"
section .text
;~~~~~~~~~~~~~~~~;
; PRINT FUNCTION ;
;~~~~~~~~~~~~~~~~;
; Input:
;	rdi - *string
print:
	push rbx                        ; Push rbx onto the stack

	mov rbx, rdi                    ; Put the value of rdi into rbx [rbx points to input string]
	mov rdx, 0                      ; Set rdx to 0 [stores length of print string]

print_countLoop:                    ;   loop marker
	cmp byte [rbx],NULL             ;   compare what rbx points to, and a null (0x00) character,
	je print_countLoopEnd           ;   if they are equal, end loop, otherwise continue
	inc rdx                         ;   increment rdx [length++]
	inc rbx                         ;   increment rbx [move to next character of input string]
	jmp print_countLoop             ;   loop again
print_countLoopEnd:
	cmp rdx, 0                      ; compare string length and 0
	je print_done                   ; if equal, skip printing [saves a syscall] and just end

	mov rax, SYS_write              ; tell the system to use SYS_write, [SYS_write uses rdx to see how many chars to print]
	mov rsi, rdi                    ; point rsi to rdi [input string]
	mov rdi, STDOUT                 ; set rdi to STDOUT (console output)
	syscall                         ; and make a system call to execute
print_done:
	pop rbx							; put the last value of the stack onto rbx
	ret								; return

;~~~~~~~~~~~~~~~~~;
; PRINTN FUNCTION ;
;~~~~~~~~~~~~~~~~~;
; Input:
;	rdi - *string
;	rsi - length
printn:
    mov rdx, rsi
	mov rax, SYS_write              ; tell the system to use SYS_write, [SYS_write uses rdx to see how many chars to print]
	mov rsi, rdi                    ; point rsi to rdi [input string]
	mov rdi, STDOUT                 ; set rdi to STDOUT (console output)
	syscall                         ; and make a system call to execute
	ret								; return

section .data
    printlnNL db NL
section .text
;~~~~~~~~~~~~~~~~~~;
; PRINTLN FUNCTION ;
;~~~~~~~~~~~~~~~~~~;
println:
	mov rax, SYS_write				; Call the system to write to STDOUT 1 character from "newLine"
	mov rdx, 1
	mov rsi, printlnNL
	mov rdi, STDOUT
	syscall
	ret
section .bss
	printcPtr resb 1
section .text
;~~~~~~~~~~~~~~~~~;
; PRINTC FUNCTION ;
;~~~~~~~~~~~~~~~~~;
; Input
;	dil - char
printc:
	mov byte [printcPtr], dil
	mov rax, SYS_write				; Call the system to write to STDOUT 1 character from "printcPtr"
	mov rdx, 1
	mov rsi, printcPtr
	mov rdi, STDOUT
	syscall
	ret

;~~~~~~~~~~~~~~~~~;
; PRINTI FUNCTION ;
;~~~~~~~~~~~~~~~~~;
; Input
;	rdi - int
printi:
	xor r8, r8

	cmp rdi, 0
	jge printi_loop

	mov byte [printcPtr], '-'
	mov rax, SYS_write
	mov rdx, 1
	mov rsi, printcPtr
	mov rdi, STDOUT
	syscall
printi_loop:
	mov rax, rdi
	div 10
	push 

%endif