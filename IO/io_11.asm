# QtSpim, part 1, assignment 1:

# Try to understand the polling example provided in io_polling.asm and run it
# with QtSpim. Next, populate the empty sub-programs in the CODING section
# below.

##########
# CODING #
##########

# Code section
.text

 
# getc: read a char from keyboard and return it in register $v0
getc:
	
	la   $t0,    0xffff0000  # $t0 = keyboard control register address
	la   $t1,    0xffff0004  # $t1 = keyboard data register address
	la 	 $t2,    0xffff0008  # $t3 = console control register address
	la   $t3, 	 0xffff000c  # $t4 = console data register address
	li 	 $t4,    10
	addi $a0,    $zero, 0        		
	addiu 	$sp,	 $sp,	 -12		 # Make room for stack
	lw		$t5,	 0($t0)
	andi 	$t5, 	 $t5, 	 1			 # 
	beq 	$t5, 	 $zero,  getc
	lw 		$v0, 	 0($t1) 			 # Store and return character in $v0
	jr $ra					 # Return




# putc: send the char in register $a0 to console
putc:
	lw 		$t5, 	0($t2)
	andi 	$t5, 	$t5, 	1
	beq 	$zero,  $t5, 	putc
	sw 		$a0, 	0($t1)	
	jr 		$ra		# Return
	
	
	
# d2i: convert the digit character in register $a0 to an integer and store it
# $v0. In case something is wrong (guess what could be wrong) store error code 1
# in $v1, else store 0.
d2i:
	la 		$t0, 	'0' 			# $ t0 = set the reg t0 equal to ascii-value of 0
	la 		$t1, 	'g' 			# $ t1 = set the reg t1 equal to ascii-value of g
	slt 	$v1, 	$a0, 	$t0		# 
	bne $v1, $zero, d2i_end			# if not ($v1==0): BranchIfNotEqual to d2i_end 
	slt $v1, $t1, $a0				
	bne $v1, $zero, d2i_end
	subu $v0, $a0, $t0




# geti: read a multi-digits integer from keyboard and store its value in
# register $v0. Assume last input character is a newline (ASCII code 10). In
# case something is wrong store an error code in $v1, else store 0.
# Error codes:
#  - 1: A character is neither a digit nor a newline
#  - 2: Overflow (integer does not fit on 32 bits)
# Use the getc and d2i routines (beware your save registers).
geti:

	addiu 	$sp, $sp, -12
	sw		$ra, 0($sp)
	sw 		$s0, 4($sp)
	sw		$s1, 8($sp)
	la 		$s0, 0
	la 		$s1, 10

loop:
	#[...]
	jal getc
	addu $a0, $v0, $zero
	jal d2i
	#[...Error handling]
	mul $s0, $s0, $s1
	addu $s0, $s0, $v0
	#[...Error handling?]
	b loop
	addu $v0, $s0, $zero
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addiu $sp, $sp, 12 #??
    jr $ra


		

#####################################################
# TEST PROGRAM FOR THE GETC, PUTC AND GETI ROUTINES #
#####################################################

# Data section
.data

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
	addiu	$a0,	$v0,	0		# Copy read char to $a0
	jal	putc				# Send char to console
	lw	$ra,	0($sp)			# Pop $ra
	addiu	$sp,	$sp,	4		# Restore stack pointer
	jr	$ra				# Return

# Same as the io_polling.asm example, but reads one integer with geti and prints
# with QtSpim syscall
testi:
	addiu	$sp,	$sp,	-8		# Make room for stack
	sw	$ra,	0($sp)			# Push $ra
	sw	$s0,	4($sp)			# Push $s0
	jal	geti				# Read integer from keyboard
	beq	$v1,	$zero,	testi_continue	# Continue if ok ($v1 == 0)...
	addiu	$v1,	$v1,	-1		# ...else check error code in $v1...
	beq	$v1,	$zero,	testi_nad_error	# ...branch to not-a-digit error
	b	testi_ovf_error			# ... branch to overflow error
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
	jal	testc			# Call test program (edit to change test program)
	la	$a0,	main_separator	# Print separator with...
	li	$v0,	4		# ...QtSpim syscall
	syscall
	j	main_loop		# Iterate
	lw	$ra,	0($sp)		# Restore $ra
	addiu	$sp,	$sp,	4	# Restore stack pointer
