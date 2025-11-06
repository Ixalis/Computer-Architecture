.data
geta: .asciiz "Please insert a: "
getb: .asciiz "Please insert b: "
getc: .asciiz "Please insert c: "
four: .float 4.0
two: .float 2.0
zero: .float 0.0
x1: .asciiz "x1 = "
x2: .asciiz "\nx2 = "
x: .asciiz "There is one solution, x = "
noSol: .asciiz "There is no real solution"

.text
.globl main
main:
	#get a
	li $v0, 4
	la $a0, geta
	syscall
	li $v0, 6
	syscall
	mov.s $f11, $f0

	#get b
	li $v0, 4
	la $a0, getb
	syscall
	li $v0, 6
	syscall
	mov.s $f12, $f0

	#get c
	li $v0, 4
	la $a0, getc
	syscall
	li $v0, 6
	syscall
	mov.s $f13, $f0
	
	#chack a
	l.s $f1, zero
	c.eq.s $f11, $f1
	bc1t no_a_sol

	#calculate delta
	mul.s $f2, $f12, $f12
	mul.s $f3, $f11, $f13
	l.s $f4, four
	mul.s $f3, $f3, $f4
	sub.s $f2, $f2, $f3

	#check delta
	c.lt.s $f2, $f1
	bc1t no_sol
	c.eq.s $f2, $f1
	bc1t one_sol
	j two_sol
	
	
	
exit:
	li $v0, 10
	syscall
	
one_sol:
	neg.s $f3, $f12
	l.s $f4, two
	mul.s $f4, $f4, $f11
	div.s $f6, $f3, $f4

	li $v0, 4
	la $a0, x
	syscall
	li $v0, 2
	mov.s $f12, $f6
	syscall
	j exit

no_sol:
	li $v0, 4
	la $a0, noSol
	syscall
	j exit

two_sol:
	sqrt.s $f2, $f2
	neg.s $f3, $f11
	l.s $f4, two
	div.s $f4, $f3, $f4
	div.s $f5, $f2, $f4

	add.s $f6, $f4, $f5
	sub.s $f7, $f4, $f5

	li $v0, 4
	la $a0, x1
	syscall
	li $v0, 2
	mov.s $f12, $f6
	syscall

	li $v0, 4
	la $a0, x2
	syscall
	li $v0, 2
	mov.s $f12, $f7
	syscall
	j exit
	
no_a_sol:
	neg.s $f3,$f13
	div.s $f6, $f3, $f12
	
	li $v0, 4
	la $a0, x
	syscall
	li $v0, 2
	mov.s $f12, $f6
	syscall
	j exit

