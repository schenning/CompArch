# IO with keyboard interrupts. Works with io_with_irq_exceptions.s interrupt
# handler; configure simulator accordingly before running this.

.text
main:
	li	$t1,	0x0000ff11	# Coprocessor initialisation
	mtc0	$t1,	$12		# Initialize status register
	la	$t1,	0xffff0000	# IO control initialisation
	lw	$t3,	0($t1)
	li	$t0,	2		# Initialize receiver control
	sw	$t0,	0($t1)
	lw	$t3,	0($t1)		# Empty IO data

wait4irq:
	addi	$t1,	$t1,	1	# Loop to wait for interrupts
	j	wait4irq
	j	wait4irq
