# PURPOSE: This program finds the maximum number of a
#          set of data items using counter.
#
# VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
# %ecx - Counter
#
# The following memory locations are used:
#
# data_items - contains the item data.
#
# first step:  as --32 -o maximum-4.o maximum-4.s
# second step: ld -melf_i386 -o maximum-4 maximum-4.o


.section .data
data_items:

#These are the data items
.long	3,67,34,222,45,75,54,34,44,33,22,11,66,0

.section .bss

.lcomm  buffer_data,    32 	# size our buffer for ascii text


.section .text
.globl _start

_start:
		mov	$0x00, %edi			# move 0 into the index register
		mov	data_items(,%edi,4), %eax	# load the first byte of data
		mov	%eax, %ebx			# since this is the first item, %eax is
							# the biggest

		xor	%ecx, %ecx			# initialize our counter

	start_loop:					# start loop

		cmp	$0x0e, %ecx			# check to see if we’ve hit the end
		je	loop_exit			
		inc	%edi				# load next value
		inc	%ecx				# increase our counter
		mov	data_items(,%edi,4), %eax	
		cmp	%ebx, %eax			# compare values
		jle	start_loop			# jump to loop beginning if the new
							# one isn’t bigger
		mov	%eax, %ebx			# move the value as the largest
		jmp	start_loop			# jump to loop beginning

	loop_exit:
		
		push	$buffer_data			# address of our buffer where we store ascii text
		push	%ebx				# our value which we want to convert
		
		call    integer2string
		add     $8, %esp

                push    $buffer_data			# Get the character count for our system call
                call    count_chars			#
                addl    $4, %esp

		movb	$0x0a, buffer_data(,%eax,1)	# write new line ('\n') symbol

		mov	%eax, %edx			# numbers of bytes we want to write
		inc	%edx				# get into account new line symbol
		mov	$0x04, %eax			# write system call
		mov	$0x01, %ebx			# will be write to stdout
		mov	$buffer_data, %ecx		# data which will be written

		int	$0x80


# %ebx is the status code for the exit system call
# and it already has the maximum-4 number
		
		mov	$0x01, %eax			# 1 is the exit() syscall
		xor	%ebx, %ebx
		int	$0x80
