.data
    prompt_a:    .asciiz "Please insert a: "
    prompt_b:    .asciiz "Please insert b: "
    prompt_c:    .asciiz "Please insert c: "
    result_x1:   .asciiz "x1 = "
    result_x2:   .asciiz "x2 = "
    one_sol:     .asciiz "There is one solution, x = "
    no_sol:      .asciiz "There is no real solution"
    newline:     .asciiz "\n"
    
    two:         .float 2.0
    four:        .float 4.0
    zero:        .float 0.0

.text
.globl main

main:
    # Prompt for a
    li $v0, 4
    la $a0, prompt_a
    syscall
    
    # Read a
    li $v0, 6
    syscall
    mov.s $f1, $f0          # $f1 = a
    
    # Prompt for b
    li $v0, 4
    la $a0, prompt_b
    syscall
    
    # Read b
    li $v0, 6
    syscall
    mov.s $f2, $f0          # $f2 = b
    
    # Prompt for c
    li $v0, 4
    la $a0, prompt_c
    syscall
    
    # Read c
    li $v0, 6
    syscall
    mov.s $f3, $f0          # $f3 = c
    
    # Calculate discriminant: delta = b^2 - 4*a*c
    mul.s $f4, $f2, $f2     # $f4 = b^2
    
    l.s $f5, four           # $f5 = 4.0
    mul.s $f6, $f5, $f1     # $f6 = 4*a
    mul.s $f6, $f6, $f3     # $f6 = 4*a*c
    
    sub.s $f4, $f4, $f6     # $f4 = delta = b^2 - 4*a*c
    
    # Check if delta < 0 (no real solution)
    l.s $f7, zero
    c.lt.s $f4, $f7
    bc1t no_solution
    
    # Check if delta == 0 (one solution)
    c.eq.s $f4, $f7
    bc1t one_solution
    
    # Two solutions: x = (-b ± sqrt(delta)) / (2*a)
two_solutions:
    # Calculate sqrt(delta)
    sqrt.s $f8, $f4         # $f8 = sqrt(delta)
    
    # Calculate -b
    neg.s $f9, $f2          # $f9 = -b
    
    # Calculate 2*a
    l.s $f10, two
    mul.s $f10, $f10, $f1   # $f10 = 2*a
    
    # Calculate x1 = (-b + sqrt(delta)) / (2*a)
    add.s $f11, $f9, $f8    # $f11 = -b + sqrt(delta)
    div.s $f12, $f11, $f10  # $f12 = x1
    
    # Calculate x2 = (-b - sqrt(delta)) / (2*a)
    sub.s $f11, $f9, $f8    # $f11 = -b - sqrt(delta)
    div.s $f13, $f11, $f10  # $f13 = x2
    
    # Print x1
    li $v0, 4
    la $a0, result_x1
    syscall
    
    li $v0, 2
    mov.s $f12, $f12
    syscall
    
    # Print newline
    li $v0, 4
    la $a0, newline
    syscall
    
    # Print x2
    li $v0, 4
    la $a0, result_x2
    syscall
    
    li $v0, 2
    mov.s $f12, $f13
    syscall
    
    j exit

one_solution:
    # x = -b / (2*a)
    neg.s $f9, $f2          # $f9 = -b
    l.s $f10, two
    mul.s $f10, $f10, $f1   # $f10 = 2*a
    div.s $f12, $f9, $f10   # $f12 = x
    
    # Print message
    li $v0, 4
    la $a0, one_sol
    syscall
    
    # Print x
    li $v0, 2
    syscall
    
    j exit

no_solution:
    # Print no solution message
    li $v0, 4
    la $a0, no_sol
    syscall
    
    j exit

exit:
    # Exit program
    li $v0, 10
    syscall