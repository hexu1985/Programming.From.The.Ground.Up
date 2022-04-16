# PURPOSE: Program that reads a string of characters from STDIN and converts
#          them to a number.
#          
#          Example: $ echo "435784" | ./maximum-4 
#
# VARIABLES: The registers have the following uses:
#
#
# The following memory locations are used:
#
# buffer_data - contains 32 bytes buffer
#
# first step:  as --32 -o maximum-4.o maximum-4.s
# second step: ld -melf_i386 -o maximum-4 maximum-4.o


.section .data

.section .bss

.lcomm  buffer_data, 32         # size our buffer for ascii text
.lcomm	counter, 1		# size of string counter


.section .text
.globl _start

_start:

		mov     $0x03, %eax             # read from a file
		xor	%ebx, %ebx		# STDIN
                mov     $buffer_data, %ecx      # the location to read into
                mov     $32, %edx		# the size of the buffer
                int     $0x80

		test    %eax, %eax              # do we have a error?
                jg     	process_stdin

	process_stdin:

		movl	%eax, counter		# in %eax number of bytes that we read
		
		mov	$0x06, %eax		# close file
		int	$0x80

		xor	%eax, %eax		# clear %eax
		mov	%ecx, %esi		# move address of our buffer to %esi

		push	%esi			# address of our buffer
		mov	counter, %eax		# lenght our string
		push	%eax

		call	number2integer		# convert ascii to hex
		add	$8, %esp

		mov	counter, %edx		# string size
		mov	$buffer_data, %ecx 	# address of a string
		mov     $0x04, %eax		# write to
                mov     $0x01, %ebx		# stdout
                int     $0x80

	exit:

		mov	$0x01, %eax		# 1 is the exit() syscall
		xor	%ebx, %ebx
		int	$0x80
