.include "linux.s"

.equ	ST_ERROR_CODE,	8
.equ	ST_ERROR_MSG,	12

.globl	error_exit
.type	error_exit,	@function

	error_exit:
			
		push	%ebp
		mov	%esp, %ebp

	# Write out error code

		mov	ST_ERROR_CODE(%ebp), %ecx
		push	%ecx
		call	count_chars
		pop	%ecx
		mov	%eax, %edx
		mov	$STDERR, %ebx
		mov	$SYS_WRITE, %eax
		int	$LINUX_SYSCALL

	# Write out error message

		mov	ST_ERROR_MSG(%ebp), %ecx
		push	%ecx
		call	count_chars
		pop	%ecx
		mov	%eax, %edx
		mov	$STDERR, %ebx
		mov	$SYS_WRITE, %eax
		int	$LINUX_SYSCALL
		push	$STDERR
		call	write_newline
	
	# Exit with status 1

		mov	$SYS_EXIT, %eax
		mov	$1, %ebx
		int	$LINUX_SYSCALL
