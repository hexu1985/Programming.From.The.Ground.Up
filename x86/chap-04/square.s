# PURPOSE: Program to illustrate how functions work
#          This program will compute the value of 2^3 + 5^2
#
# Everything in the main program is stored in registers,
# so the data section doesn’t have anything.
#
# first step:  as --32 -o square.o square.s
# second step: ld -melf_i386 -o square square.o


.section .data

.section .text

.globl _start

_start:
		push	$3				# push second argument
		call	square				# call the function

		mov	%eax, %ebx			# save our square as exit code
		mov	$0x01, %eax			# 1 is the exit() syscall
		int	$0x80

# PURPOSE: This function is used to compute
#          the value of a square.
#
# INPUT: First argument - the base number
#        Second argument - the square to
#        raise it to
#
# OUTPUT: Will give the result as a return value
#
# NOTES: The square must be 1 or greater
#
# VARIABLES: %ebx - holds the base number
#            -4(%ebp) - holds the current result

.type	square, @function

	square:

		push	%ebp				# save old base pointer
		mov	%esp, %ebp			# make stack pointer the base pointer
		sub	$4, %esp			# get room for our local storage

		mov	8(%ebp), %ebx			# put first argument in %ebx
		push	%ebx				
		pop	%eax				# our number in %eax

		mul	%ebx				# multiply two numbers. By default mul is using %eax as multiplicand

		mov	%ebp, %esp			# restore the stack pointer
                pop	%ebp				# restore the base pointer
		ret
