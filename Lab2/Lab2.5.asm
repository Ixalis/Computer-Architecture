# MIPS (MARS/SPIM)
# Compute factorial of a non-negative integer.
# If input < 0 → print error message.

.data
prompt:     .asciiz "Enter a non-negative integer: "
result_msg: .asciiz "Factorial = "
error_msg:  .asciiz "A factorial for your number cannot be found.\n"
newline:    .asciiz "\n"

.text
.globl main
main:
    # Prompt user
    li      $v0, 4
    la      $a0, prompt
    syscall

    # Read integer
    li      $v0, 5
    syscall
    move    $t0, $v0            # t0 = n

    # Check if input < 0
    bltz    $t0, print_error

    # Factorial logic
    li      $t1, 1              # result = 1
    li      $t2, 1              # i = 1

fact_loop:
    bgt     $t2, $t0, fact_done
    mul     $t1, $t1, $t2
    addiu   $t2, $t2, 1
    j       fact_loop

fact_done:
    # Print result
    li      $v0, 4
    la      $a0, result_msg
    syscall

    li      $v0, 1
    move    $a0, $t1
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall
    j       exit_prog

print_error:
    li      $v0, 4
    la      $a0, error_msg
    syscall

exit_prog:
    li      $v0, 10
    syscall
