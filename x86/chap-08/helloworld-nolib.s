# PURPOSE: This program writes the message "hello world" and
#          exits

# first step:  as --32 -o helloworld-nolib.o helloworld-nolib.s
# second step: ld -melf_i386 -o helloworld-nolib helloworld-nolib.o


.include "linux.s"

.section	.data

helloworld:	.ascii "hello world\n"
helloworld_end:	.equ	helloworld_len, helloworld_end - helloworld

.section	.text

.globl	_start
	_start:

		mov	$STDOUT, %ebx
		mov	$helloworld, %ecx
		mov	$helloworld_len, %edx
		mov	$SYS_WRITE, %eax
		int	$LINUX_SYSCALL
		
		mov	$0, %ebx
		mov	$SYS_EXIT, %eax
		int	$LINUX_SYSCALL

