.data
getu: .asciiz "please insert u: "
getv: .asciiz "please insert v: "
geta: .asciiz "please insert a: "
getb: .asciiz "please insert b: "
getc: .asciiz "please insert c: "
getd: .asciiz "please insert d: "
gete: .asciiz "please insert e: "
two: .float 2.0
four: .float 4.0
six: .float 6.0
ans: .asciiz "\nf(x) = "

.text
.globl main
main:
	#get u
	li $v0, 4
	la $a0, getu
	syscall
	li $v0, 6
	syscall
	mov.s $f19, $f0
	
	#get v
	li $v0, 4
	la $a0, getv
	syscall
	li $v0, 6
	syscall
	mov.s $f20, $f0
	
	#get a
	li $v0, 4
	la $a0, geta
	syscall
	li $v0, 6
	syscall
	mov.s $f21, $f0
	
	#get b
	li $v0, 4
	la $a0, getb
	syscall
	li $v0, 6
	syscall
	mov.s $f22, $f0
	
	#get c
	li $v0, 4
	la $a0, getc
	syscall
	li $v0, 6
	syscall
	mov.s $f23, $f0
	
	#get d
	li $v0, 4
	la $a0, getd
	syscall
	li $v0, 6
	syscall
	mov.s $f24, $f0
	
	#get e
	li $v0, 4
	la $a0, gete
	syscall
	li $v0, 6
	syscall
	mov.s $f25, $f0
	
	#calcculate a/6,b/4,....
	l.s $f1, six
	div.s $f21, $f21, $f1
	l.s $f1, four
	div.s $f22, $f22, $f1
	l.s $f1, two
	div.s $f23, $f23, $f1
	mul.s $f24, $f24, $f24
	mul.s $f25, $f25, $f25
	
	#calculate u6,v6,...
	mul.s $f11, $f19, $f19
	mul.s $f13, $f11, $f11
	mul.s $f15, $f13, $f11
	mul.s $f12, $f20, $f20
	mul.s $f14, $f12, $f12
	mul.s $f16, $f14, $f12
	
	#calculate
	sub.s $f1, $f15, $f16
	mul.s $f1, $f1, $f21
	sub.s $f2, $f13, $f14
	mul.s $f2, $f2, $f22
	sub.s $f3, $f11, $f12
	mul.s $f3, $f3, $f23
	add.s $f4, $f1, $f2
	add.s $f4, $f4, $f3
	add.s $f5, $f24, $f25
	div.s $f6, $f4, $f5
	
	#print
	li $v0, 4
	la $a0, ans
	syscall
	li $v0, 2
	mov.s $f12, $f6
	syscall

exit:
	li $v0, 10
	syscall



