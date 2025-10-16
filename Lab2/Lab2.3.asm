.data
a: .asciiz"a = "
b: .asciiz"b = "
print_gcd: .asciiz"\nGCD = "
print_lcm: .asciiz"\nLCM = "
syntax_error: .asciiz"The inputs consist of something that is not an positive integer."

.text
.globl main
main:
	#get value
	li $v0, 4
	la $a0, a
	syscall
	li $v0, 5
	syscall
	move $t0, $v0
	
	li $v0, 4
	la $a0, b
	syscall
	li $v0, 5
	syscall
	move $t1, $v0
	
	mul $t2, $t0, $t1
	ble $t2, $zero, Error
	ble $t1, $zero, Error
	
	j con
GCD:
	bgt $t0, $t1, tt
	sub $t1, $t1, $t0
	j con
tt:
	sub $t0, $t0, $t1
con:	
	bne $t0, $t1, GCD
	
	#LCM
	div $t2, $t1
	
	#print result
	li $v0, 4
	la $a0, print_lcm
	syscall
	li $v0, 1
	mflo $a0
	syscall
	
	li $v0, 4
	la $a0, print_gcd
	syscall
	li $v0, 1
	move $a0, $t1
	syscall
	
	j Exit
Error:
	li $v0, 4
	la $a0, syntax_error
	syscall
	j Exit

Exit:
	li $v0, 10
	syscall