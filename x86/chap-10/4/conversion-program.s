# instead of writing is_negative function
# we check is parameter negative or not in
# integer2string function itself


.include "linux.s"

.section .data

# This is where it will be stored
tmp_buffer:	.ascii	"\0\0\0\0\0\0\0\0\0\0\0"

.section .bss

.lcomm	signed, 1			# signed or not signed digit

.section .text

.globl _start

	_start:
		
		mov	%esp, %ebp
		push	$tmp_buffer	# Storage for the result
		push	$824		# Number to convert

		call	integer2string
		add	$8, %esp

		mov	%bx, signed

		push	$tmp_buffer	# Get the character count for our system call
		call	count_chars
		addl	$4, %esp

		mov	%eax, %edx		# The count goes in %edx for SYS_WRITE
		mov	$SYS_WRITE, %eax	# Make the system call
		mov	$STDOUT, %ebx
		mov	$tmp_buffer, %ecx

		int	$LINUX_SYSCALL

		push	$STDOUT		# Write a carriage return
		call	write_newline

	exit:

		mov	$SYS_EXIT, %eax	# Exit
		mov	signed, %ebx
		int	$LINUX_SYSCALL
