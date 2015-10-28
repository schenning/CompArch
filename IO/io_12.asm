# QtSpim, part 1, assignment 2:

# Starting from the code you wrote in assignment 1, code the versions with time
# out of the getc, putc and geti routines. These new versions take an
# additionnal parameter in register $a1 which is the address in memory of a time
# out flag. If this flag is set to 1 during an I/O transaction, the transaction
# must abort and return the error code 3 in $v1. Note: the d2i routine is the
# same as in assigment 1.

##########
# CODING #
##########

# Data section
.data

time_out_flag:
.word 0					# The time-out flag

# Code section
.text

# getc: read a char from keyboard and return it in register $v0
getc:

# putc: send the char in register $a0 to console
putc:

# d2i: convert the digit character in register $a0 to an integer and store it
# $v0. In case something is wrong (guess what could be wrong) store an error
# code in $v1, else store 0.
d2i:

# geti: read a multi-digits integer from keyboard and store its value in
# register $v0. Assume last input character is a newline (ASCII code 10). In
# case something is wrong store an error code in $v1, else store 0.
# Error codes:
#  - 1: A character is neither a digit nor a newline
#  - 2: Overflow (integer does not fit on 32 bits)
#  - 3: Time out
# Use the getc and d2i routines (beware your save registers).
geti:

#####################################################
# TEST PROGRAM FOR THE GETC, PUTC AND GETI ROUTINES #
#####################################################

# Data section
.data

to_error_message:
.asciiz "Time out"			# Time out error message
nad_error_message:
.asciiz "Not a digit"			# Not a digit error message
ovf_error_message:
.asciiz "Overflow"			# Overflow error message

# Code section
.text

# Same as the io_polling.asm example (read one char), but using the getc and
# putc sub-programs
testc:
	addiu	$sp,	$sp,	-4		# Make room for stack
	sw	$ra,	0($sp)			# Push $ra
	jal	getc				# Read char from keyboard
	bne	$v1,	$zero,	testc_to_error	# Branch if time out error (return status is not 0)
	addiu	$a0,	$v0,	0		# Copy read char to $a0
	jal	putc				# Send char to console
	lw	$ra,	0($sp)			# Pop $ra
	addiu	$sp,	$sp,	4		# Restore stack pointer
	jr	$ra				# Return
testc_to_error:
	la	$a0,	to_error_message	# Print time out error message...
	li	$v0,	4			# ...with QtSpim...
	syscall					# ...syscall...
	lw	$ra,	0($sp)			# Pop $ra
	addiu	$sp,	$sp,	4		# Restore stack pointer
	jr	$ra				# Return

# Same as the io_polling.asm example, but reads one integer with geti
testi:
	addiu	$sp,	$sp,	-8		# Make room for stack
	sw	$ra,	0($sp)			# Push $ra
	sw	$s0,	4($sp)			# Push $s0
	jal	geti				# Read integer from keyboard
	beq	$v1,	$zero,	testi_continue	# Continue if ok ($v1 == 0)...
	addiu	$v1,	$v1,	-1		# ...else check error code in $v1...
	beq	$v1,	$zero,	testi_nad_error	# ...branch to not-a-digit error
	addiu	$v1,	$v1,	-1
	beq	$v1,	$zero,	testi_ovf_error	# ... branch to overflow error
	b	testi_to_error			# ... branch to time out error
testi_continue:
	addiu	$a0,	$v0,	0		# Copy $v0 to $a0
	li	$v0,	1			# Print integer with QtSpim...
	syscall					# ...syscall...
	j	testi_return			# ...and return
testi_nad_error:
	la	$a0,	nad_error_message
	li	$v0,	4
	syscall
	j	testi_return
testi_ovf_error:
	la	$a0,	ovf_error_message
	li	$v0,	4
	syscall
	j	testi_return
testi_to_error:
	la	$a0,	to_error_message
	li	$v0,	4
	syscall
testi_return:
	lw	$ra,	0($sp)			# Pop $ra
	lw	$s0,	4($sp)			# Pop $s0
	addiu	$sp,	$sp,	8		# Restore stack pointer
	jr	$ra				# Return

# Data section
.data

main_separator:
.asciiz "\n"				# A separator

# Code section
.text

# Main routine, iteratively call selected test
main:
	addiu	$sp,	$sp,	-4	# Make room for stack
	sw	$ra,	0($sp)		# Push $ra
main_loop:
	la	$a1,	time_out_flag	# $a1 = address of time out flag
	jal	testi			# Call test program (edit to change test program)
	la	$a0,	main_separator	# Print separator with...
	li	$v0,	4		# ...QtSpim syscall
	syscall
	j	main_loop		# Iterate
	lw	$ra,	0($sp)		# Restore $ra
	addiu	$sp,	$sp,	4	# Restore stack pointer
