    .data
buffer: .space 1024
tem: .space 4
input_file: .asciiz "LAB/raw_input.txt"
promt: .asciiz "--Student personal information--"
name: .asciiz "\nName: "
id: .asciiz "\nID: "
address: .asciiz "\nAddress: "
age: .asciiz "\nAge: "
region: .asciiz "\nRegion: "
output_file: .asciiz "LAB/format_ted_result.txt"
    .text
    .globl main
main:
# Open ( f o r r e a di n g ) a f i l e
	li $v0 , 13 # system c a l l f o r open f i l e
	la $a0 , input_file # i n p u t f i l e name
	li $a1 , 0 # Open f o r r e a di n g ( f l a g s a r e 0 : read , 1 : w ri t e )
	li $a2 , 0 # mode i s i g n o r e d
	syscall # open a f i l e ( f i l e d e s c r i p t o r r e t u r n e d i n $v0 )
	move $s6 , $v0 # s a ve the f i l e d e s c r i p t o r

    # Read from f i l e
	li $v0 , 14 # system c a l l f o r re ad
	move $a0 , $s6 # f i l e d e s c r i p t o r
	la $a1 , buffer# a d d r e s s o f b u f f e r re ad
	li $a2 , 1024
	syscall # re ad f i l e

# Cl o se the f i l e
	li $v0, 16 # system c a l l f o r c l o s e f i l e
	move $a0, $s6 # f i l e d e s c r i p t o r t o c l o s e
	syscall # c l o s e f i l e
	
	# Open ( f o r w ri ti n g ) a f i l e t h a t d oe s not e x i s t
	li $v0 , 13 # system c a l l f o r open f i l e
	la $a0 , output_file # output f i l e name
	li $a1 , 1 # Open f o r w ri ti n g ( f l a g s a r e 0 : read , 1 : w ri t e )
	li $a2 , 0 # mode i s i g n o r e d
	syscall # open a f i l e ( f i l e d e s c r i p t o r r e t u r n e d i n $v0 )
	move $s6 , $v0 # s a ve the f i l e d e s c r i p t o r

    	#Print
    	la $t0, buffer
    	
    	li $v0, 4
    	la $a0, promt
    	syscall
    	li $v0, 15
    	move $a0, $s6
    	la $a1, promt
    	li $a2, 32
    	syscall
    	
    	li $v0, 4
    	la $a0, name
    	syscall
    	li $v0, 15
    	move $a0, $s6
    	la $a1, name
    	li $a2, 7
    	syscall
    	jal print
    	
    	li $v0, 4
    	la $a0, id
    	syscall
    	li $v0, 15
    	move $a0, $s6
    	la $a1, id
    	li $a2, 5
    	syscall
    	jal print
    	
    	li $v0, 4
    	la $a0, address
    	syscall
    	li $v0, 15
    	move $a0, $s6
    	la $a1, address
    	li $a2, 10
    	syscall
    	jal print
    	
    	li $v0, 4
    	la $a0, age
    	syscall
    	li $v0, 15
    	move $a0, $s6
    	la $a1, age
    	li $a2, 6
    	syscall
    	jal print
    	
    	li $v0, 4
    	la $a0, region
    	syscall
    	li $v0, 15
    	move $a0, $s6
    	la $a1, region
    	li $a2, 9
    	syscall
    	jal print
    	
exit:
	li $v0, 10
	syscall
print:
	lb $t1, 0($t0)
	la $t2, tem
	sb $t1, 0($t2)
	beqz $t1, end_print
	beq $t1, ',', end_print
	move $a0, $t1
	li $v0, 11
	syscall
	li $v0, 15
    	move $a0, $s6
    	la $a1, tem
    	li $a2, 1
    	syscall
	addiu $t0, $t0, 1
	j print

end_print:
	addiu $t0, $t0, 1
	jr $ra
	