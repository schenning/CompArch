# Polling-based IO (simple) example

.text
main:					# Initialize registers with peripheral addresses
	la	$t0,	0xffff0000	# $t0 = keyboard control register address
	la	$t1,	0xffff0004	# $t1 = keyboard data register address
	la	$t2,	0xffff0008	# $t2 = console (screen) control register address
	la	$t3,	0xffff000c	# $t3 = console (screen) data register address
	li	$t4,	10		# $t4 = ASCII code for newline (10)

wait4char:
	lw	$t5,	0($t0)			# Load $t5 with keyboard control register
	andi	$t5,	$t5,	1		# Mask all bits except LSB
	beq	$t5,	$zero,	wait4char	# Loop if LSB unset (no character from keyboard)
	lw	$v0,	0($t1)			# Store received character in $v0

wait4console1:
	lw	$t5,	0($t2)			# Load $t5 with console control register
	andi	$t5,	$t5,	1		# Mask all bits except LSB
	beq	$zero,	$t5,	wait4console1	# Loop if LSB unset (console busy)
	sw	$v0,	0($t3)			# Send character received from keyboard to console

wait4console2:
	lw	$t5,	0($t2)			# Load $t5 with console control register
	andi	$t5,	$t5,	1		# Mask all bits except LSB
	beq	$zero,	$t5,	wait4console2	# Loop if LSB unset (console busy)
	sw	$t4,	0($t3)			# Send newline character to console

	b main			# Go to main (infinite loop)
