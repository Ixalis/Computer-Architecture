# MIPS (MARS/SPIM)
# Read 5 integers, adjust each to nearest multiple of 4
# (round down on tie), then print results.

        .eqv N 5

.data
prompt_in:   .asciiz "Enter 5 integers (one per line):\n"
prompt_out:  .asciiz "Adjusted array: "
space:       .asciiz " "
newline:     .asciiz "\n"

.align 2
arr:         .space 20            # 5 words × 4 bytes = 20 bytes

.text
.globl main
main:
    # Prompt input
    li      $v0, 4
    la      $a0, prompt_in
    syscall

    # Read N integers into arr
    la      $t0, arr              # t0 = &arr[0]
    li      $t1, N                # t1 = count
read_loop:
    beq     $t1, $zero, read_done
    li      $v0, 5                # read_int
    syscall
    sw      $v0, 0($t0)
    addiu   $t0, $t0, 4
    addiu   $t1, $t1, -1
    j       read_loop
read_done:

    # Process: snap each to nearest multiple of 4
    la      $t0, arr
    li      $t1, N
proc_loop:
    beq     $t1, $zero, proc_done
    lw      $t2, 0($t0)           # t2 = value
    andi    $t3, $t2, 3           # remainder = n mod 4 (bits)
    beq     $t3, $zero, keep_val

    li      $t4, 1
    beq     $t3, $t4, r_is_1
    li      $t4, 2
    beq     $t3, $t4, r_is_2
    # r = 3 -> n + 1
    addiu   $t2, $t2, 1
    j       store_back

r_is_1:
    addiu   $t2, $t2, -1
    j       store_back
r_is_2:
    addiu   $t2, $t2, -2
    j       store_back
keep_val:
    # unchanged
store_back:
    sw      $t2, 0($t0)
    addiu   $t0, $t0, 4
    addiu   $t1, $t1, -1
    j       proc_loop
proc_done:

    # Print result
    li      $v0, 4
    la      $a0, prompt_out
    syscall

    la      $t0, arr
    li      $t1, N
print_loop:
    beq     $t1, $zero, print_done
    lw      $a0, 0($t0)
    li      $v0, 1                # print_int
    syscall

    addiu   $t1, $t1, -1
    addiu   $t0, $t0, 4
    bgtz    $t1, print_space

    # last element → newline
    li      $v0, 4
    la      $a0, newline
    syscall
    j       print_done

print_space:
    li      $v0, 4
    la      $a0, space
    syscall
    j       print_loop

print_done:
    li      $v0, 10
    syscall
