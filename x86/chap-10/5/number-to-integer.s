
# PURPOSE:  Convert an integer number to a octal string
#           for display. 
#
# INPUT:   A buffer large enough to hold the largest
#          possible number An integer to convert
#
# OUTPUT:  The buffer will be overwritten with the
#          decimal string
#
# Variables:
#
#  %ecx will hold the count of characters processed
#  %eax will hold the current value
#  %edi will hold the base (10)

.equ	ST_VALUE,	8
.equ	ST_BUFFER,	12

.globl	number2integer
.type	number2integer,	@function

number2integer:

		push	%ebp		# Normal function beginning
		mov	%esp, %ebp

		xor	%ecx, %ecx	# Current character count

		mov	ST_VALUE(%ebp), %ecx	# move count of bytes in %ecx
		mov	ST_BUFFER(%ebp), %esi	# move address of our buffer in %esi
		push	%esi
		pop	%edi			# also we use same buffer as a storage
						# for our converted string

	conversion_loop:

		xor	%eax, %eax	# clear registers
		xor	%edx, %edx
		lodsb			# take first byte from %esi and load in into %eax

		sub	$'0', %eax
		imul	$10, %ebx
		add	%ebx, %eax
		stosb

		dec	%ecx			# decrement counter
		test	%ecx, %ecx		# is it zero?
		jnz	conversion_loop

		mov  %ebp, %esp
		pop  %ebp
		ret
