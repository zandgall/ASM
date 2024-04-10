; A bunch of global definitions that are used by system functions and other things  

%ifndef SYSDEF
%define SYSDEF
section .data
    NL equ 10
    NULL equ 0
    true equ 1
    false equ 0
    TRUE equ 1
    FALSE equ 0

    STDIN equ 0
    STDOUT equ 1
    STDERR equ 2

    SYS_read equ 0
    SYS_write equ 1
    SYS_open equ 2
    SYS_close equ 3
    SYS_mmap equ 9
    SYS_munmap equ 11
    SYS_form equ 57
    SYS_exit equ 60
    SYS_creat equ 85
    SYS_time equ 201
    SYS_getrandom equ 318

    PROT_NONE equ 0x0
    PROT_READ equ 0x1
    PROT_WRITE equ 0x2
    PROT_EXECUTE equ 0x4
    MAP_PRIVATE equ 0x2
    MAP_ANONYMOUS equ 0x20
    MAP_FAILED equ -1
%endif