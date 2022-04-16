# PURPOSE: Research the lseek system call.
#          Rewrite the add-year program to
#          open the source file for both
#          reading and writing (use $2 for
#          the read/write mode), and write
#          the modified records back to the
#          same file they were read from.

.include "linux.s"
.include "record-def.s"
#.include "error-handler.s"

.section .data

input_file_name:	.ascii "test.dat\0"

.section .bss

.lcomm	record_buffer,	RECORD_SIZE
.lcomm	seek_position,	4

# Stack offsets of local variables

.equ	ST_INPUT_DESCRIPTOR,	-4

.section .text

.globl	_start
	_start:
		
		mov	%esp, %ebp	# Copy stack pointer and make room for local variables
		sub	$8, %esp

		mov	ST_ARGC(%ebp), %eax	# put number of arguments in eax
		mov	ST_ARGV_1(%ebp), %ebx	# define filename
		cmp	$2, %eax		# we always have at least one argument
		jge	open_fd_read_and_write	# if we have arguments then open a file
	
		mov	$input_file_name, %ebx	# if we do not have arguments, put
						# defined filename in ebx
		

		# Open file for reading and writening
	open_fd_read_and_write:

		mov	$SYS_OPEN, %eax		# open file
		mov	$2, %ecx		# This says to open read and write
		mov	$0666, %edx		# file permissions
		int	$LINUX_SYSCALL
		
		test	%eax, %eax		# check if eax is zero
		jge	no_error

		add	$8, %esp
		call	error_handler
		jmp	exit
	
	no_error:

		mov	%eax, ST_INPUT_DESCRIPTOR(%ebp)
		xor	%eax, %eax
		

	first_record:

		push	ST_INPUT_DESCRIPTOR(%ebp)
		push	$record_buffer
		call	read_record
		add	$8, %esp

		# Returns the number of bytes read.
		# If it isn’t the same number we
		# requested, then it’s either an
		# end-of-file, or an error, so we’re
		# quitting
		
		cmp	$RECORD_SIZE, %eax
		jne	exit

		# Increment the age

		incl	record_buffer + RECORD_AGE

		# Write the record out

		mov     seek_position, %ecx             # offset
		call	lseek

		push	ST_INPUT_DESCRIPTOR(%ebp)
		push	$record_buffer
		call	write_record
		add	$8, %esp
		
		mov	$RECORD_SIZE, %eax
                add     %eax, seek_position

                mov     seek_position, %ecx             # offset
		call    lseek

                test    %eax, %eax                      # check if eax is zero
                jge     first_record

                add     $8, %esp
                call    error_handler
                jmp     exit

		mov     $0x13, %eax                     # seek position of a record
		mov     ST_INPUT_DESCRIPTOR(%ebp), %ebx # in a file
		mov     $1, %edx			# since beginning of a file
		int     $LINUX_SYSCALL

		test    %eax, %eax                     # check if eax is zero
		jge     first_record

		add     $8, %esp
		call    error_handler
		jmp     exit


		jmp	first_record

	exit:

		mov	$SYS_EXIT, %eax
		mov	$0, %ebx
		int	$LINUX_SYSCALL

	lseek:

                mov     $0x13, %eax                     # seek position of a record
                mov     ST_INPUT_DESCRIPTOR(%ebp), %ebx # in a file
                xor     %edx, %edx                      # since beginning of a file
                int     $LINUX_SYSCALL
		ret


		
