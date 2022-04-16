# PURPOSE: Write a program that will add a single 
#          record to the file by reading the data from
#          the keyboard. Remember, you will have to make 
#          sure that the data has at least one null
#          character at the end, and you need to
#          have a way for the user to indicate
#          they are done typing. Because we have not
#          gotten into characters to numbers conversion,
#          you will not be able to read the age in from
#          the keyboard, so you’ll have to have a default age

.include "linux.s"
.include "record-def.s"
#.include "error-handler.s"

.section .data

input_file_name:	.ascii	"test.dat\0"

enter_name:		.asciz	"Enter your firstname: "
enter_surname:		.asciz	"Enter your lastname: "
enter_your_address:	.asciz	"Enter your address: "


.section .bss

.lcomm	chunk,	320	# chunk of a record, without age


# Stack offsets of local variables

.equ	ST_INPUT_DESCRIPTOR,	-4

.section .text

.globl	_start
	_start:
		
		mov	%esp, %ebp		# Copy stack pointer and make room for local variables
		sub	$8, %esp

                mov     ST_ARGC(%ebp), %eax     # put number of arguments in eax
                mov     ST_ARGV_1(%ebp), %ebx   # define filename
                cmp     $2, %eax                # we always have at least one argument
                jge     open_fd_read_and_write  # if we have arguments then open a file

                mov     $input_file_name, %ebx  # if we do not have arguments, put
                                                # defined filename in ebx

        open_fd_read_and_write:

                # Open file for reading and writening

                mov     $SYS_OPEN, %eax         # open file
                mov     $2, %ecx                # This says to open read and write
                mov     $0666, %edx             # file permissions
                int     $LINUX_SYSCALL
		test    %eax, %eax              # check if eax is zero
                jl      error

                mov     %eax, ST_INPUT_DESCRIPTOR(%ebp)
                xor     %eax, %eax

		xor	%eax, %eax		# end-of-string symbol
		push	%eax			
		mov	$enter_name, %ecx	# "counter"
		push	%ecx			

		call	string_size	
		add	$8, %esp

		call	show_message
		test    %eax, %eax              # check if eax is zero
                jl      error

		xor	%eax, %eax		
		mov	$chunk, %edi		# our buffer where we store information
		mov	$RECORD_AGE, %ecx	# size our chunk without age
		repnz	stosw			# fill our chunk with zeroes
	
		mov	$RECORD_LASTNAME, %edx	# put size of our first field in %edx
		dec	%edx			# because we always have to end our record with 0x00
		mov	$chunk, %ecx		# put address of our chunk into %eax
		
		call	read_kbd
                test    %eax, %eax              # check if eax is zero
                jl      error

		xor	%eax, %eax
		push	%eax
		mov	$enter_surname, %ecx
		push	%ecx

		call	string_size
		add	$8, %esp

		call	show_message
                test    %eax, %eax              # check if eax is zero
                jl      error


		mov	$RECORD_LASTNAME, %ebx	# put size of our first field in %ebx
		push	%ebx			# save it 
		leal	chunk(,%ebx,1),	%ecx	# save address of our second record in %ecx
		pop	%edx			# restore size
		dec	%edx			# because we always have to end our record with 0x00

		call    read_kbd
                test    %eax, %eax              # check if eax is zero
                jl      error

                xor     %eax, %eax
                push    %eax
                mov     $enter_your_address, %ecx
                push    %ecx

                call    string_size
                add     $8, %esp

                call    show_message
                test    %eax, %eax              # check if eax is zero
                jl      error

		mov	$RECORD_AGE, %edx	# take record age position
		sub	$RECORD_ADDRESS, %edx	# substract it from record address position
		dec	%edx			# we have 320-80-1 = 239 byte record field
		mov	$RECORD_ADDRESS, %ebx	# skip 80 bytes
		leal	chunk(,%ebx,1), %ecx

		call	read_kbd
		test    %eax, %eax              # check if eax is zero
                jl      error

		
	last_field:				# this marker for debugging only

                mov     $RECORD_AGE, %ebx	# our last field
                leal    chunk(,%ebx,1), %ecx	# skip 320 bytes
                movl    $33, (%ecx)		# put our age to the last field

		xor	%ecx, %ecx		# offset
		inc	%ecx			# 1
		call	lseek			# move pointer
                add     $8, %esp

		test    %eax, %eax              # check if eax is zero
                jl      error


	append_to_file:

		mov	$SYS_WRITE, %eax
		mov	ST_INPUT_DESCRIPTOR(%ebp), %ebx # in a file
		mov	$chunk, %ecx			# buffer with our information
		mov	$RECORD_SIZE, %edx		# buffer size
		int	$LINUX_SYSCALL

                test    %eax, %eax              # check if eax is zero
                jl      error

		mov	$SYS_CLOSE, %eax		# close file
		mov	ST_INPUT_DESCRIPTOR(%ebp), %ebx
		int	$LINUX_SYSCALL

	exit:

		mov	$SYS_EXIT, %eax
		mov	$0, %ebx
		int	$LINUX_SYSCALL

	lseek:

                mov     $0x13, %eax                     # set position of a record
                mov     ST_INPUT_DESCRIPTOR(%ebp), %ebx # in a file
                mov     $0x02, %edx                     # at the end of a file
                int     $LINUX_SYSCALL
		ret


	show_message:

		mov	$0x04, %eax		# write to
		mov	$0x01, %ebx		# stdout
		int	$0x80
		ret
	
	read_kbd:

		mov	$0x03, %eax		# read
		xor	%ebx, %ebx		# from stdin
		int	$0x80		
		ret

        error:

                call    error_handler
                jmp     exit

