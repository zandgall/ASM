;~~~~CONTENTS~~~~~~
; strtoi(rdi: *string, rsi: base (0=detect) ) -> rax = output, rdi = *string end of int
;	~ Follows the gnu libc description of "strtol" https://www.gnu.org/software/libc/manual/html_node/Parsing-of-Integers.html
;	~ Can automatically detect base if rsi=0
;	~ Scans string to parse an integer. Uses base given, or detect if given 0

%ifndef STR_S
%define STR_S
%include "sysdef.1.1.s"

section .text
strtoi:
	xor r9, r9 					; negative flag (r9 = 0)
	xor rax, rax 				; rax = 0
;~~Check for sign~~~~~~~~~~~~~~~;
	cmp byte [rdi], '-'			; check if '-' at beginning of string..
	jne strtoi_check_plus		; if there isn't, go to check for plus
	mov r9, 1 					; if there is, set negative flag
	inc rdi						; and move to next char
	jmp strtoi_check_base		; and then check for base
  strtoi_check_plus:
	cmp byte [rdi], '+'			; check if '+' at beginning of string..
	jne strtoi_check_base		; if there isn't, move to check for base
	inc rdi						; if there is, move to next char (don't set negative flag)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

;~~Detect base~~~~~~~~~~~~~~~~~~,
  strtoi_check_base: 			;
	cmp rsi, 0 					; if base (rsi) is given, (not 0)
	jne strtoi_skip_base_prefix	; -> Skip base prefix (break from Detect base)
								;
	cmp byte [rdi], '0'			; if string doesn't start with '0',
	jne strtoi_base_10			; -> Use Base 10
	inc rdi						; move to next char
	cmp byte [rdi], 'x'			; if string starts with "0x",
	je strtoi_base_16 			; -> Use Base 16
	cmp byte [rdi], 'X' 		; if string starts with "0X",
	je strtoi_base_16 			; -> Use Base 16
	cmp byte [rdi], 'b' 		; if string starts with "0b",
	je strtoi_base_2 			; -> Use Base 2
	cmp byte [rdi], 'B' 		; if string starts with "0B",
	je strtoi_base_2 			; -> Use Base 2
	mov rsi, 8 					; rsi = 8
	dec rdi						; move to the previous '0' in case input just = '0'
	jmp strtoi_parse_loop		; -> Parsing
 								;
  strtoi_base_2:				;~~~Use Base 2~~~
	mov rsi, 2 					; rsi = 2
	inc rdi 					; move to next char
	jmp strtoi_parse_loop 		; -> Parsing
  strtoi_base_16:				;~~~Use Base 16~~~
	mov rsi, 16 				; rsi = 16
	inc rdi 					; move to next char
	jmp strtoi_parse_loop		; -> Parsing
  strtoi_base_10: 				;~~~Use Base 10~~~
	mov rsi, 10 				; rsi = 10
	jmp strtoi_parse_loop		; -> Parsing
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

;~~Skip base prefix~~~~~~~~~~~~~, - Even if base is given, check for base prefix and skip over it
  strtoi_skip_base_prefix:		;
	cmp byte [rdi], '0'			; if string doesn't start with '0'
	jne strtoi_parse_loop		; -> Parsing (no base prefix to skip)
	inc rdi						; move to next char
	cmp byte [rdi], 'x'			; if string starts with "0x",
	je strtoi_verify_base_16	; -> Verify Base 16
	cmp byte [rdi], 'X'			; if string starts with "0X",
	je strtoi_verify_base_16	; -> Verify Base 16
	cmp byte [rdi], 'b'			; if string starts with "0b",
	je strtoi_verify_base_2		; -> Verify Base 2
	cmp byte [rdi], 'B'			; if string starts with "0B",
	je strtoi_verify_base_2		; -> Verify Base 2
								; must be base 8,
	cmp rsi, 8 					; if rsi != 8
	jne strtoi_return 			; -> Return
								;
	jmp strtoi_parse_loop		; -> Parsing (skipped base 8 prefix)
								;
  strtoi_verify_base_16:		;~~~Verify Base 16~~~
	inc rdi						; move to next char
	cmp rsi, 16 				; if rsi != 16
	jne strtoi_return 			; -> Return
								; else
	jmp strtoi_parse_loop		; -> Parsing
								;
  strtoi_verify_base_2:			;~~~Verify Base 2~~~
	inc rdi 					; move to next char
	cmp rsi, 2 					; if rsi != 2
	jne strtoi_return 			; -> Return
								; else
	jmp strtoi_parse_loop		; -> Parsing
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

;~~Parsing~~~~~~~~~~~~~~~~~~~~~~,
  strtoi_parse_loop: 			;
	mul rsi 					; multiply current output by base. (i.e. if rax=1235 and base=10, rax will be 12350 to leave space to add to the final digit)
	cmp byte [rdi], 0x61		; if char code > 0x61
	jae strtoi_c_lower			; -> Process Lowercase
	cmp byte [rdi], 0x41		; if char code > 0x41
	jae strtoi_c_upper			; -> Process Uppercase
								; (Process as num)
	sub byte [rdi], 0x30		; subtract 0x30 to produce numeric value
	jmp strtoi_c_done			; -> Parsed Char
  strtoi_c_upper:				;~~~Process Uppercase~~~
	sub byte [rdi], 0x37		; subtract 0x37 to produce numeric value
	jmp strtoi_c_done			; -> Parsed Char
  strtoi_c_lower:				;~~~Process Lowercase~~~
	sub byte [rdi], 0x57		; subtract 0x57 to produce numeric value
  strtoi_c_done:				;~~~Parsed Char~~~
	add al, byte [rdi]			; add numeric value to rax
	inc rdi						; move to next character,
	cmp byte [rdi], 0x00		; if character is 0x00,
	je strtoi_check_sign_flag	; -> Check Sign Flag (done parsing)
	cmp byte [rdi], 0x20		; if character is 0x20, (space/' ' character)
	je strtoi_check_sign_flag	; -> Check Sign Flag (done parsing)
								;
	jmp strtoi_parse_loop		; -> Parsing
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

;~~Check Sign Flag~~~~~~~~~~~~~~,
  strtoi_check_sign_flag:		;
	cmp r9, 0 					; if r9 (negative flag) is 0
	je strtoi_return 			; -> Return
								;
	mov rsi, rax				; rsi = rax
	xor rax, rax				; rax = 0
	sub rax, rsi 				; rax = -rsi
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

;~~~Return~~~~~~~~~~~~~~~~~~~~~~;
  strtoi_return:				;
	ret 						;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

%endif