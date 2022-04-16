.include "linux.s"
.include "record-def.s"

.section .data

file_name:	.ascii	"test.dat\0"

record_buffer_ptr:	.long	0

.section .bss

.section .text

# Main program
.globl	_start

	_start:

# These are the locations on the stack where
# we will store the input and output descriptors
# (FYI - we could have used memory addresses in
# a .data section instead)

.equ	ST_INPUT_DESCRIPTOR,	-4
.equ	ST_OUTPUT_DESCRIPTOR,	-8

		mov	%esp, %ebp	# Copy the stack pointer to %ebp
		sub	$8, %esp	# Allocate space to hold the file descriptors

		mov	ST_ARGC(%ebp), %eax	# put number of arguments in eax
		mov	ST_ARGV_1(%ebp), %ebx	# define filename
		cmp	$2, %eax		# we always have at least one argument
		jge	open_fd_read		# if we have arguments then open a file
	
		mov	$file_name, %ebx	# if we do not have arguments, put
						# defined filename in ebx

	open_fd_read:

		mov	$SYS_OPEN, %eax		# open file
		mov	$0, %ecx		# This says to open read-only
		mov	$0666, %edx		# file permissions
		int	$LINUX_SYSCALL
		
		test	%eax, %eax		# check if eax is zero
		jge	no_error

		add	$8, %esp
		call	error_handler
		jmp	exit


	no_error:

		mov	%eax, ST_INPUT_DESCRIPTOR(%ebp)	# Save file descriptor
		
		# Even though it’s a constant, we are
		# saving the output file descriptor in
		# a local variable so that if we later
		# decide that it isn’t always going to
		# be STDOUT, we can change it easily.

		movl	$STDOUT, ST_OUTPUT_DESCRIPTOR(%ebp)

	record_read_loop:

		push	$RECORD_SIZE
		call	allocate
		mov	%eax, record_buffer_ptr

		push	ST_INPUT_DESCRIPTOR(%ebp)
		push	record_buffer_ptr
		call	read_record
		add	$8, %esp

		# Returns the number of bytes read.
		# If it isn’t the same number we
		# requested, then it’s either an
		# end-of-file, or an error, so we’re
		# quitting

		cmp	$RECORD_SIZE, %eax
		jne	finished_reading
		
		# Otherwise, print out the first name
		# but first, we must know it’s size
		
		mov	record_buffer_ptr, %eax
		add	$RECORD_FIRSTNAME, %eax
		push	%eax
		call	count_chars
		add	$4, %esp

		mov	%eax, %edx
		mov	ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
		mov	$SYS_WRITE, %eax

		mov	record_buffer_ptr, %ecx
		add	$RECORD_FIRSTNAME, %ecx
		int	$LINUX_SYSCALL
		
		push	ST_OUTPUT_DESCRIPTOR(%ebp)
		call	write_newline
		add	$4, %esp
		
		jmp	record_read_loop
		
	finished_reading:

		mov	ST_INPUT_DESCRIPTOR(%ebp), %ebx		# Close file
		mov	$SYS_CLOSE, %eax
		int	$LINUX_SYSCALL	

		xor	%ebx, %ebx				# our exit code
	
	exit:
	
		push	record_buffer_ptr
		call	deallocate

		mov	$SYS_EXIT, %eax				# exit to OS
		int	$LINUX_SYSCALL

