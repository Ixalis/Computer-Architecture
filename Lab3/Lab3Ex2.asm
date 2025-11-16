.data
    prompt_u:    .asciiz "Please insert u: "
    prompt_v:    .asciiz "Please insert v: "
    prompt_a:    .asciiz "Please insert a: "
    prompt_b:    .asciiz "Please insert b: "
    prompt_c:    .asciiz "Please insert c: "
    prompt_d:    .asciiz "Please insert d: "
    prompt_e:    .asciiz "Please insert e: "
    result_msg:  .asciiz "Result: "
    newline:     .asciiz "\n"
    
    n_steps:     .float 10000.0    # Number of steps for integration
    four:        .float 4.0
    five:        .float 5.0
    two:         .float 2.0
    one:         .float 1.0

.text
.globl main

main:
    # Read u (lower bound)
    li $v0, 4
    la $a0, prompt_u
    syscall
    li $v0, 6
    syscall
    mov.s $f1, $f0          # $f1 = u
    
    # Read v (upper bound)
    li $v0, 4
    la $a0, prompt_v
    syscall
    li $v0, 6
    syscall
    mov.s $f2, $f0          # $f2 = v
    
    # Read a
    li $v0, 4
    la $a0, prompt_a
    syscall
    li $v0, 6
    syscall
    mov.s $f3, $f0          # $f3 = a
    
    # Read b
    li $v0, 4
    la $a0, prompt_b
    syscall
    li $v0, 6
    syscall
    mov.s $f4, $f0          # $f4 = b
    
    # Read c
    li $v0, 4
    la $a0, prompt_c
    syscall
    li $v0, 6
    syscall
    mov.s $f5, $f0          # $f5 = c
    
    # Read d
    li $v0, 4
    la $a0, prompt_d
    syscall
    li $v0, 6
    syscall
    mov.s $f6, $f0          # $f6 = d
    
    # Read e
    li $v0, 4
    la $a0, prompt_e
    syscall
    li $v0, 6
    syscall
    mov.s $f7, $f0          # $f7 = e
    
    # Calculate step size: h = (v - u) / n
    sub.s $f8, $f2, $f1     # $f8 = v - u
    l.s $f9, n_steps        # $f9 = n
    div.s $f10, $f8, $f9    # $f10 = h (step size)
    
    # Initialize sum = 0
    mtc1 $zero, $f11
    cvt.s.w $f11, $f11      # $f11 = sum = 0.0
    
    # Initialize counter i = 0
    li $t0, 0               # $t0 = i
    l.s $f21, n_steps
    
integration_loop:
    # Check if i >= n
    mtc1 $t0, $f20          # Move integer to FP register
    cvt.s.w $f20, $f20      # Convert to float
    c.le.s $f21, $f20
    bc1t end_loop
    
    # Calculate x = u + i * h
    mtc1 $t0, $f12          # Move integer to FP register
    cvt.s.w $f12, $f12      # Convert i to float
    mul.s $f12, $f12, $f10  # i * h
    add.s $f12, $f1, $f12   # x = u + i * h
    
    # Calculate f(x) = (ax^6 + bx^5 + cx) / (d^4 + e^3)
    # First calculate numerator: ax^6 + bx^5 + cx
    
    # Calculate x^2
    mul.s $f13, $f12, $f12  # $f13 = x^2
    
    # Calculate x^5 = x^2 * x^2 * x
    mul.s $f14, $f13, $f13  # x^4
    mul.s $f14, $f14, $f12  # x^5
    
    # Calculate x^6 = x^5 * x
    mul.s $f15, $f14, $f12  # x^6
    
    # Calculate ax^6
    mul.s $f16, $f3, $f15   # ax^6
    
    # Calculate bx^5
    mul.s $f17, $f4, $f14   # bx^5
    
    # Calculate cx
    mul.s $f18, $f5, $f12   # cx
    
    # Sum numerator: ax^6 + bx^5 + cx
    add.s $f16, $f16, $f17
    add.s $f16, $f16, $f18  # $f16 = numerator
    
    # Calculate denominator: d^4 + e^3
    mul.s $f17, $f6, $f6    # d^2
    mul.s $f17, $f17, $f17  # d^4
    
    mul.s $f18, $f7, $f7    # e^2
    mul.s $f18, $f18, $f7   # e^3
    
    add.s $f17, $f17, $f18  # $f17 = d^4 + e^3
    
    # Calculate f(x) = numerator / denominator
    div.s $f19, $f16, $f17  # $f19 = f(x)
    
    # Add to sum
    add.s $f11, $f11, $f19
    
    # Increment counter
    addi $t0, $t0, 1
    j integration_loop

end_loop:
    # Multiply sum by h (step size)
    mul.s $f11, $f11, $f10
    
    # Print result
    li $v0, 4
    la $a0, result_msg
    syscall
    
    li $v0, 2
    mov.s $f12, $f11
    syscall
    
    # Exit
    li $v0, 10
    syscall