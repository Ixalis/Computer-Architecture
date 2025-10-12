# F = ((a + 10) * (b - d) * (c - 2a)) / (a + b + c)
# Prints quotient and remainder.

.data
inputA:   .asciiz "Insert a: "
inputB:   .asciiz "Insert b: "
inputC:   .asciiz "Insert c: "
inputD:   .asciiz "Insert d: "
f:        .asciiz "\nF = "
remain:   .asciiz "\nremainder "
newline:  .asciiz "\n"

# Optional: if you want to store results in memory labels too
q_label:  .word 0
r_label:  .word 0

.text
.globl main
main:
    # --- Read a ---
    li   $v0, 4
    la   $a0, inputA
    syscall

    li   $v0, 5
    syscall
    move $s0, $v0          # a -> $s0

    # --- Read b ---
    li   $v0, 4
    la   $a0, inputB
    syscall

    li   $v0, 5
    syscall
    move $s1, $v0          # b -> $s1

    # --- Read c ---
    li   $v0, 4
    la   $a0, inputC
    syscall

    li   $v0, 5
    syscall
    move $s2, $v0          # c -> $s2

    # --- Read d ---
    li   $v0, 4
    la   $a0, inputD
    syscall

    li   $v0, 5
    syscall
    move $s3, $v0          # d -> $s3

    # --- Compute pieces ---
    # denom = a + b + c
    addu $t0, $s0, $s1
    addu $t0, $t0, $s2     # $t0 = denom

    # ap10 = a + 10
    addiu $t1, $s0, 10     # $t1 = a + 10

    # bd = b - d
    subu $t2, $s1, $s3     # $t2 = b - d

    # c2a = c - 2a
    sll  $t4, $s0, 1       # $t4 = 2*a
    subu $t3, $s2, $t4     # $t3 = c - 2a

    # numerator = (a+10)*(b-d)*(c-2a)
    mul  $t5, $t1, $t2     # (a+10)*(b-d)
    mul  $t5, $t5, $t3     # numerator

    # --- Divide numerator by denom ---
    # Assumption given: denom != 0, so no check needed
    div  $t5, $t0
    mflo $t6               # quotient
    mfhi $t7               # remainder

    # Optional: store results into labels (memory)
    la   $t8, q_label
    sw   $t6, 0($t8)
    la   $t8, r_label
    sw   $t7, 0($t8)

    # --- Print results ---
    li   $v0, 4
    la   $a0, f
    syscall

    move $a0, $t6          # print quotient after "F = "
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, remain
    syscall

    move $a0, $t7          # print remainder
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    # done
    li   $v0, 10
    syscall
