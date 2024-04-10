; PRINT FUNCTION ;
; input string - rdi ;

%include "baseData.1.0.s"
; PRINT FUNCTION ;
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

section .data
    printlnNL db NL    
section .text
; PRINTLN FUNCTION ;
println:
	mov rax, SYS_write				; Call the system to write to STDOUT 1 character from "newLine"
	mov rdx, 1
	mov rsi, printlnNL
	mov rdi, STDOUT
	syscall
	ret