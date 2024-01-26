    .intel_syntax noprefix
    .global _start

    .text
_start:
    # write(1, message, 13)
    mov     rax, 1                # system call 1 is write
    mov     rdi, 1                # file handle 1 is stdout
    mov     rsi, message          # address of string to output
    mov     rdx, 13               # number of bytes
    syscall                       # invoke operating system to do the write

    # exit(0)
    mov     rax, 60               # system call 60 is exit
    xor     rdi, rdi              # we want return code 0
    syscall                       # invoke operating system to exit

message:
    .ascii  "Hello, world\n"
