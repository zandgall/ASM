%ifndef BASEDATA_1_0
%define BASEDATA_1_0
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
    SYS_form equ 57
    SYS_exit equ 60
    SYS_creat equ 85
    SYS_time equ 201
%endif