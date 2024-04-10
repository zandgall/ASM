%include "str.1.0.s"
%include "stdio.1.0.s"

section .data
	welcome_msg db "Welcome to your math quiz! Answer the following questions and view your score at the very end.",NL,NL,NULL
	prompt db "Question #",NULL
	colon db ": ",NULL
	operation db "+-*%"
	equal db " = ",NULL

	correct db "Correct! Good job!",NL,NULL
	incorrect db "Incorrect :(",NL,NULL

	score1 db "You Got ",NULL
	score2 db " Correct, and ",NULL
	score3 db " Incorrect! Meaning you got ",NULL
	score4 db " / ",NULL
	score5 db " Correct! Or ",NULL
	score6 db "%!",NL,NULL

	score_perfect db "Wow! You got everything!",NL,NULL
	score_good db "Very well done :)",NL,NULL
	score_okay db "Good job!",NL,NULL
	score_bad db "You'll get better next time!",NL,NULL

	input_len equ 32 ; declaring max 32 character input length
section .bss
	inputStr resb input_len
	randomOut resb 3 ; read 3 random values each loop
section .text
global _start
_start:
	lea rdi, [welcome_msg]
	call print
	lea r12, [1]
	lea r13, [0]
	lea r14, [0]

quizLoop:
	lea rax, [SYS_getrandom]
	lea rdi, [randomOut]
	lea rsi, [3]
	xor rdx, rdx
	syscall
	xor rax, rax
	mov al, byte[rdi]
	lea rsi, [20]
	div rsi
	mov byte[rdi], dl
	xor rdx, rdx
	inc rdi
	mov al, byte[rdi]
	lea rsi, [4]
	div rsi
	mov byte[rdi], dl
	xor rdx, rdx
	inc rdi
	mov al, byte[rdi]
	lea rsi, [20]
	div rsi
	mov byte[rdi], dl

	lea rdi, [prompt]
	call print
	mov rdi, r12
	call printi
	lea rdi, [colon]
	call print
	xor rdi, rdi
	mov dil, byte[randomOut]
	call printi
	lea rdi, [0x20]
	call printc
	xor rsi, rsi
	mov sil, byte[randomOut+1]
	lea rdi, [operation+rsi]
	mov rsi, 1
	call printn
	lea rdi, [0x20]
	call printc
	xor rdi, rdi
	mov dil, byte[randomOut+2]
	call printi
	lea rdi, [equal]
	call print

	xor rax, rax
	mov al, byte[randomOut]
	xor rsi, rsi
	mov sil, byte[randomOut+2]
	cmp byte[randomOut+1], 1
	je opSub
	cmp byte[randomOut+1], 2
	je opMul
	cmp byte[randomOut+1], 3
	je opMod
opAdd:
	add al, sil
	jmp opEnd
opSub:
	sub rax, rsi ; need integer subtraction in case of negative
	jmp opEnd
opMul:
	mul sil
	jmp opEnd
opMod:
	xor rdx, rdx
	div rsi
	mov rax, rdx
opEnd:
	mov rbx, rax
	lea rdi, [inputStr]
	mov rsi, input_len
	call input
	lea rdi, [inputStr]
	xor rsi, rsi
	call strtoi
	cmp rax, -1
	je quizEnd
	cmp rbx, rax
	jne ansIncorrect
ansCorrect:
	inc r13
	lea rdi, [correct]
	jmp ansEnd
ansIncorrect:
	inc r14
	lea rdi, [incorrect]
ansEnd:
	call print
	call println

	inc r12
	jmp quizLoop
quizEnd:
	dec r12
	cmp r12, 0
	je mainEnd

	lea rdi, [score1]
	call print
	lea rdi, [r13]
	call printi
	lea rdi, [score2]
	call print
	lea rdi, [r14]
	call printi
	lea rdi, [score3]
	call print
	lea rdi, [r13]
	call printi
	lea rdi, [score4]
	call print
	lea rdi, [r12]
	call printi
	lea rdi, [score5]
	call print
	lea rax, [r13]
	lea rsi, [100]
	mul rsi
	div r12
	lea r12, [rax]
	lea rdi, [rax]
	call printi
	lea rdi, [score6]
	call print

	cmp r12, 100
	je perfect
	cmp r12, 80
	jge good
	cmp r12, 60
	jge okay
	lea rdi, [score_bad]
	call print
	jmp printFeedback
perfect:
	lea rdi, [score_perfect]
	jmp printFeedback
good:
	lea rdi, [score_good]
	jmp printFeedback
okay:
	lea rdi, [score_okay]
printFeedback:
	call print
mainEnd:
	mov rax, SYS_exit
	mov rdi, 0
	syscall