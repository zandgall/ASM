#!/bin/bash

if [ $# -eq 0 ];
then
	echo "$0: Syntax $0 [assembly file] (optional: -d)"
	exit 1
elif [ $# -lt 2 ];
then
	eval "yasm -f elf -m amd64 $1 && ld ${1%.*}.o -o ${1%.*}"
	exit 0
elif [[ $2 = "-d" ]];
then
	eval "yasm -f elf -m amd64 -g dwarf2 $1 && ld ${1%.*}.o -o ${1%.*}"
	exit 0
else
	eval "yasm -f elf -m amd64 $1 && ld ${1%.*}.o -o ${1%.*}"
	exit 0
fi
