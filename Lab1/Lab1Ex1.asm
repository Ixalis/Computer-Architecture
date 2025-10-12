# Program: Hello, World!
.data

greeting: .asciiz "\nHello,"
input: .asciiz"Enter your name: "
name: .space 100
.text 
main: 
	li $v0,4
	la $a0, input
	syscall
	
	li $v0,8
	la $a0, name
	li $a1, 100
	syscall
	
	li $v0, 4
	la $a0, greeting
	syscall
	
	li $v0, 4
	la $a0, name
	syscall
	
	
