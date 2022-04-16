# PURPOSE: Program to manage memory usage - allocates
#          and deallocates memory as requested
#
# NOTES: The programs using these routines will ask
#        for a certain size of memory. We actually
#        use more than that size, but we put it
#        at the beginning, before the pointer
#        we hand back. We add a size field and
#        an AVAILABLE/UNAVAILABLE marker. So, the
#        memory looks like this
#
# ###############################################################
# # Available Marker # Size of memory # Actual memory locations #
# ###############################################################
#                                       ^--Returned pointer
#                                          points here
#
# The pointer we return only points to the actual
# locations requested to make it easier for the
# calling program. It also allows us to change our
# structure without the calling program having to
# change at all.

.section .data

###### GLOBAL VARIABLES #######

# This points to the beginning of the memory we are managing

heap_begin:	.long	0

# This points to one location past the memory we are managing

current_break:	.long	0

##### STRUCTURE INFORMATION ###
# size of space for memory region header
.equ	HEADER_SIZE,	8

# Location of the "available" flag in the header
.equ	HDR_AVAIL_OFFSET,	0

# Location of the size field in the header
.equ	HDR_SIZE_OFFSET,	4


########## CONSTANTS ##########

.equ	UNAVAILABLE,	0 	# This is the number we will use to mark
				# space that has been given out

.equ	AVAILABLE,	1	# This is the number we will use to mark
				# space that has been returned, and is
				# available for giving

.equ	SYS_BRK,	45	# system call number for the break
				# system call

.equ	LINUX_SYSCALL,	0x80	# make system calls easier to read

.section .text

######### FUNCTIONS ###########


# allocate #

# PURPOSE: This function is used to grab a section of
#          memory. It checks to see if there are any
#          free blocks, and, if not, it asks Linux
#          for a new one.
#
# PARAMETERS: This function has one parameter - the size
#             of the memory block we want to allocate
#
# RETURN VALUE: This function returns the address of the
#               allocated memory in %eax. If there is no
#               memory available, it will return 0 in %eax
#
##### PROCESSING #######
# Variables used:
#    %ecx - hold the size of the requested memory
#           (first/only parameter)
#    %eax - current memory region being examined
#    %ebx - current break position
#    %edx - size of current memory region
#
# We scan through each memory region starting with
# heap_begin. We look at the size of each one, and if
# it has been allocated. If it’s big enough for the
# requested size, and its available, it grabs that one.
# If it does not find a region large enough, it asks
# Linux for more memory. In that case, it moves
# current_break up

.globl	allocate
.type	allocate,	@function

.equ	ST_MEM_SIZE,	8			# stack position of the memory size
						# to allocate

allocate:

		push	%ebp			# standard function stuff
		mov	%esp, %ebp

		mov	current_break, %eax	# move variable to %eax
		test	%eax, %eax		# if %eax is not zero
		jne	continue_allocation	# then we don not have to init
						# allocation

# If the brk system call is called with 0 in %ebx, it
# returns the last valid usable address

                mov     $SYS_BRK, %eax		# find out where the break is
                xor     %ebx, %ebx
                int     $LINUX_SYSCALL

                inc     %eax			# %eax now has the last valid
						# address, and we want the
						# memory location after that

                mov     %eax, current_break     # store the current break
                mov     %eax, heap_begin


continue_allocation:

		mov	ST_MEM_SIZE(%ebp), %ecx	# %ecx will hold the size
						# we are looking for (which is the first
						# and only parameter)
		mov	heap_begin, %eax	# %eax will hold the current
						# search location
		mov	current_break, %ebx	# %ebx will hold the current
						# break

alloc_loop_begin:				# here we iterate through each
						# memory region

		cmp	%ebx, %eax		# need more memory if these are equal
		je	move_break

		mov	HDR_SIZE_OFFSET(%eax), %edx	# Grab the size of this memory

		cmp	$UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)	# If the space is unavailable, go to the
		je	next_location		# next one

		cmp	%edx, %ecx		# If the space is available, compare
		jle	allocate_here		# the size to the needed size. If its
						# big enough, go to allocate_here

next_location:

		add	$HEADER_SIZE, %eax	# The total size of the memory
		add	%edx, %eax		# region is the sum of the size
						# requested (currently stored
						# in %edx), plus another 8 bytes
						# for the header (4 for the
						# AVAILABLE/UNAVAILABLE flag,
						# and 4 for the size of the
						# region). So, adding %edx and $8
						# to %eax will get the address
						# of the next memory region

		jmp	alloc_loop_begin	# go look at the next location

allocate_here:					# if we’ve made it here,
						# that means that the
						# region header of the region
						# to allocate is in %eax
		# Mark space as unavailable

		movl	$UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
		add	$HEADER_SIZE, %eax	# move %eax past the header to
						# the usable memory (since
						# that’s what we return)

		mov	%ebp, %esp		# return from the function
		pop	%ebp
		
		ret


move_break:					# if we’ve made it here, that
						# means that we have exhausted
						# all addressable memory, and
						# we need to ask for more.
						# %ebx holds the current
						# endpoint of the data
						# and %ecx holds its size
						# we need to increase %ebx to
						# where we _want_ memory
						# to end, so we
		add	$HEADER_SIZE, %ebx	# add space for the headers
		add	%ecx, %ebx		# add space to the break for
						# the data requested
						# now its time to ask Linux
						# for more memory
		push	%eax
		push	%ecx
		push	%ebx			# save needed registers

		mov	$SYS_BRK, %eax		# reset the break (%ebx has
						# the requested break point)
		int	$LINUX_SYSCALL

		# under normal conditions, this should
		# return the new break in %eax, which
		# will be either 0 if it fails, or
		# it will be equal to or larger than
		# we asked for. We don’t care
		# in this program where it actually
		# sets the break, so as long as %eax
		# isn’t 0, we don’t care what it is
		

		test	%eax, %eax		# check for error conditions
		je	error
		pop	%ebx			# restore saved registers
		pop	%ecx

		pop	%eax
		
		# set this memory as unavailable, since we’re about to
		# give it away

		movl	$UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
		
		# set the size of the memory

		mov	%ecx, HDR_SIZE_OFFSET(%eax)

		# move %eax to the actual start of usable memory.
		# %eax now holds the return value
		
		add	$HEADER_SIZE, %eax
		mov	%ebx, current_break	# save the new break

                mov     %ebp, %esp              # return from the function
                pop     %ebp

                ret


error:

		xor	%eax, %eax		# on error, we return zero

		mov	%ebp, %esp
		pop	%ebp
		
		ret
####### END OF FUNCTION #######


# deallocate #

# PURPOSE: The purpose of this function is to give back
#          a region of memory to the pool after we’re done
#          using it.
#
# PARAMETERS: The only parameter is the address of the memory
#             we want to return to the memory pool.
#
# RETURN VALUE: There is no return value
#
# PROCESSING: If you remember, we actually hand the program the
#             start of the memory that they can use, which is
#             8 storage locations after the actual start of the
#             memory region. All we have to do is go back
#             8 locations and mark that memory as available,
#             so that the allocate function knows it can use it.

.globl	deallocate
.type	deallocate,	@function

# stack position of the memory region to free
.equ	ST_MEMORY_SEG,	4

deallocate:

# since the function is so simple, we
# don’t need any of the fancy function stuff

# get the address of the memory to free
# (normally this is 8(%ebp), but since
# we didn’t push %ebp or move %esp to
# %ebp, we can just do 4(%esp)

		mov	ST_MEMORY_SEG(%esp), %eax

		# get the pointer to the real beginning of the memory
		sub	$HEADER_SIZE, %eax

		# mark it as available
		movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)

		# return
		ret
####### END OF FUNCTION #########
