# Wiener Filter - User inputs file paths
.data
prompt_in:  .asciiz "Enter input file path: "
prompt_out: .asciiz "Enter output file path: "
newline:    .asciiz "\n"
space:      .asciiz " "
label_out:  .asciiz "Filtered output: "
label_mmse: .asciiz "MMSE: "
err_msg:    .asciiz "Error: Cannot open file\n"
minus_sign: .asciiz "-"
dot_sign:   .asciiz "."

num_buf:    .space 16
buf_in:     .space 4096
fname_in:   .space 256    # Buffer for input filename
fname_out:  .space 256    # Buffer for output filename

# arrays (Q1 ints, 10 items)
.align 2
arr_d:      .space 40
arr_w:      .space 40
arr_x:      .space 40
arr_y:      .space 40

sum_dx: .word 0
sum_xx: .word 0
sum_e2: .word 0

.text
.globl main
main:
    # Ask for input file path
    li   $v0, 4
    la   $a0, prompt_in
    syscall
    
    # Read input filename
    li   $v0, 8
    la   $a0, fname_in
    li   $a1, 256
    syscall
    
    # Remove newline from input filename
    la   $t0, fname_in
remove_newline_in:
    lb   $t1, 0($t0)
    beq  $t1, 10, found_newline_in  # 10 = '\n'
    beq  $t1, 13, found_newline_in  # 13 = '\r'
    beqz $t1, done_newline_in
    addi $t0, $t0, 1
    j    remove_newline_in
found_newline_in:
    sb   $zero, 0($t0)
done_newline_in:
    
    # Ask for output file path
    li   $v0, 4
    la   $a0, prompt_out
    syscall
    
    # Read output filename
    li   $v0, 8
    la   $a0, fname_out
    li   $a1, 256
    syscall
    
    # Remove newline from output filename
    la   $t0, fname_out
remove_newline_out:
    lb   $t1, 0($t0)
    beq  $t1, 10, found_newline_out
    beq  $t1, 13, found_newline_out
    beqz $t1, done_newline_out
    addi $t0, $t0, 1
    j    remove_newline_out
found_newline_out:
    sb   $zero, 0($t0)
done_newline_out:

    # Open and read input file
    la   $a0, fname_in
    li   $a1, 0
    li   $a2, 0
    li   $v0, 13
    syscall
    bltz $v0, error_exit
    move $s0, $v0

    move $a0, $s0
    la   $a1, buf_in
    li   $a2, 4096
    li   $v0, 14
    syscall
    bltz $v0, error_exit
    move $s1, $v0

    # Null-terminate
    la   $t0, buf_in
    add  $t0, $t0, $s1
    sb   $zero, 0($t0)

    # Close input
    move $a0, $s0
    li   $v0, 16
    syscall

    # Parse input
    la   $a0, buf_in
    move $a1, $s1
    la   $a2, arr_d
    la   $a3, arr_w
    jal  parse_input

    # Build x = d + w
    li   $t0, 0
build_x_loop:
    beq  $t0, 10, build_x_done
    sll  $t1, $t0, 2
    la   $t2, arr_d
    add  $t2, $t2, $t1
    lw   $t3, 0($t2)
    la   $t2, arr_w
    add  $t2, $t2, $t1
    lw   $t4, 0($t2)
    add  $t5, $t3, $t4
    la   $t2, arr_x
    add  $t2, $t2, $t1
    sw   $t5, 0($t2)
    addi $t0, $t0, 1
    j    build_x_loop
build_x_done:

    # Compute Wiener filter
    jal  compute_wiener

    # Print "Filtered output: "
    la   $a0, label_out
    li   $v0, 4
    syscall

    # Print y values
    li   $s0, 0
print_y_loop:
    beq  $s0, 10, print_y_done
    sll  $t0, $s0, 2
    la   $t1, arr_y
    add  $t1, $t1, $t0
    lw   $a0, 0($t1)
    jal  print_q1
    la   $a0, space
    li   $v0, 4
    syscall
    addi $s0, $s0, 1
    j    print_y_loop
print_y_done:

    # Print newline
    la   $a0, newline
    li   $v0, 4
    syscall

    # Print "MMSE: "
    la   $a0, label_mmse
    li   $v0, 4
    syscall

    # Calculate and print MMSE
    jal  compute_mmse
    move $a0, $v0
    jal  print_q1
    
    la   $a0, newline
    li   $v0, 4
    syscall

    # Write to output file
    la   $a0, fname_out
    li   $a1, 1
    li   $a2, 0
    li   $v0, 13
    syscall
    bltz $v0, skip_file
    move $s7, $v0
    
    # Write "Filtered output: "
    move $a0, $s7
    la   $a1, label_out
    li   $a2, 17
    li   $v0, 15
    syscall
    
    # Write each y value
    li   $s0, 0
write_y_loop:
    beq  $s0, 10, write_y_done
    sll  $t0, $s0, 2
    la   $t1, arr_y
    add  $t1, $t1, $t0
    lw   $a0, 0($t1)
    move $a1, $s7
    jal  write_q1_to_file
    
    # Write space
    move $a0, $s7
    la   $a1, space
    li   $a2, 1
    li   $v0, 15
    syscall
    
    addi $s0, $s0, 1
    j    write_y_loop
write_y_done:
    
    # Write newline
    move $a0, $s7
    la   $a1, newline
    li   $a2, 1
    li   $v0, 15
    syscall
    
    # Write "MMSE: "
    move $a0, $s7
    la   $a1, label_mmse
    li   $a2, 6
    li   $v0, 15
    syscall
    
    # Write MMSE value
    jal  compute_mmse
    move $a0, $v0
    move $a1, $s7
    jal  write_q1_to_file
    
    # Write final newline
    move $a0, $s7
    la   $a1, newline
    li   $a2, 1
    li   $v0, 15
    syscall
    
    # Close file
    move $a0, $s7
    li   $v0, 16
    syscall
skip_file:

    # Exit
    li   $v0, 10
    syscall

error_exit:
    la   $a0, err_msg
    li   $v0, 4
    syscall
    li   $v0, 10
    syscall

# Parse input
parse_input:
    move $t0, $a0
    add  $t9, $a0, $a1
    move $t1, $a2
    move $t2, $a3
    li   $t3, 0

parse_loop:
    beq  $t3, 20, parse_done
    
skip_ws:
    beq  $t0, $t9, parse_done
    lbu  $t4, 0($t0)
    beq  $t4, 32, next_ws
    beq  $t4, 9, next_ws
    beq  $t4, 10, next_ws
    beq  $t4, 13, next_ws
    j    parse_num
next_ws:
    addi $t0, $t0, 1
    j    skip_ws

parse_num:
    li   $t5, 1
    li   $t6, 0
    li   $t7, 0
    
    lbu  $t4, 0($t0)
    bne  $t4, 45, parse_int
    li   $t5, -1
    addi $t0, $t0, 1

parse_int:
    beq  $t0, $t9, make_num
    lbu  $t4, 0($t0)
    blt  $t4, 48, check_dot
    bgt  $t4, 57, check_dot
    addi $t4, $t4, -48
    mul  $t6, $t6, 10
    add  $t6, $t6, $t4
    addi $t0, $t0, 1
    j    parse_int

check_dot:
    bne  $t4, 46, make_num
    addi $t0, $t0, 1
    
    beq  $t0, $t9, decimal_zero
    lbu  $t4, 0($t0)
    blt  $t4, 48, decimal_zero
    bgt  $t4, 57, decimal_zero
    addi $t7, $t4, -48
    addi $t0, $t0, 1
    
skip_extra_decimals:
    beq  $t0, $t9, make_num
    lbu  $t4, 0($t0)
    blt  $t4, 48, make_num
    bgt  $t4, 57, make_num
    addi $t0, $t0, 1
    j    skip_extra_decimals
    
decimal_zero:
    li   $t7, 0

make_num:
    mul  $t6, $t6, 10
    add  $t6, $t6, $t7
    mul  $t6, $t6, $t5
    
    blt  $t3, 10, store_d
store_w:
    sw   $t6, 0($t2)
    addi $t2, $t2, 4
    j    parse_next
store_d:
    sw   $t6, 0($t1)
    addi $t1, $t1, 4

parse_next:
    addi $t3, $t3, 1
    j    parse_loop

parse_done:
    jr   $ra

compute_wiener:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    sw   $zero, sum_dx
    sw   $zero, sum_xx

    li   $t0, 0
accum_loop:
    beq  $t0, 10, accum_done
    sll  $t1, $t0, 2
    
    la   $t2, arr_d
    add  $t2, $t2, $t1
    lw   $t3, 0($t2)
    la   $t2, arr_x
    add  $t2, $t2, $t1
    lw   $t4, 0($t2)
    
    mult $t3, $t4
    mflo $t5
    lw   $t6, sum_dx
    add  $t6, $t6, $t5
    sw   $t6, sum_dx
    
    mult $t4, $t4
    mflo $t5
    lw   $t6, sum_xx
    add  $t6, $t6, $t5
    sw   $t6, sum_xx
    
    addi $t0, $t0, 1
    j    accum_loop
accum_done:

    lw   $t0, sum_dx
    lw   $t1, sum_xx
    beq  $t1, $zero, h_zero
    
    li   $t2, 10
    mult $t0, $t2
    mflo $t0
    
    div  $t0, $t1
    mflo $s6
    j    compute_y
h_zero:
    li   $s6, 0
compute_y:

    li   $t0, 0
y_loop:
    beq  $t0, 10, y_done
    sll  $t1, $t0, 2
    la   $t2, arr_x
    add  $t2, $t2, $t1
    lw   $t3, 0($t2)
    
    mult $s6, $t3
    mflo $t4
    li   $t5, 10
    div  $t4, $t5
    mflo $t4
    
    la   $t2, arr_y
    add  $t2, $t2, $t1
    sw   $t4, 0($t2)
    
    addi $t0, $t0, 1
    j    y_loop
y_done:

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

compute_mmse:
    sw   $zero, sum_e2
    
    li   $t0, 0
mmse_loop:
    beq  $t0, 10, mmse_done
    sll  $t1, $t0, 2
    
    la   $t2, arr_d
    add  $t2, $t2, $t1
    lw   $t3, 0($t2)
    
    la   $t2, arr_y
    add  $t2, $t2, $t1
    lw   $t4, 0($t2)
    
    sub  $t5, $t3, $t4
    
    mult $t5, $t5
    mflo $t6
    li   $t7, 10
    div  $t6, $t7
    mflo $t6
    
    lw   $t8, sum_e2
    add  $t8, $t8, $t6
    sw   $t8, sum_e2
    
    addi $t0, $t0, 1
    j    mmse_loop
mmse_done:
    lw   $t0, sum_e2
    li   $t1, 10
    div  $t0, $t1
    mflo $v0
    jr   $ra

print_q1:
    move $t0, $a0
    bltz $t0, print_neg
    j    print_digits
print_neg:
    li   $a0, 45
    li   $v0, 11
    syscall
    neg  $t0, $t0
print_digits:
    li   $t1, 10
    div  $t0, $t1
    mflo $t2
    mfhi $t3
    
    move $a0, $t2
    li   $v0, 1
    syscall
    
    li   $a0, 46
    li   $v0, 11
    syscall
    
    move $a0, $t3
    li   $v0, 1
    syscall
    
    jr   $ra

write_q1_to_file:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s0, 12($sp)
    sw   $s1, 8($sp)
    sw   $s2, 4($sp)
    sw   $s3, 0($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    bgez $s0, write_q1_pos
    
    move $a0, $s1
    la   $a1, minus_sign
    li   $a2, 1
    li   $v0, 15
    syscall
    
    sub  $s2, $zero, $s0
    j    write_q1_calc
    
write_q1_pos:
    move $s2, $s0
    
write_q1_calc:
    li   $t0, 10
    div  $s2, $t0
    mflo $s3
    mfhi $t1
    
    move $s2, $t1
    
    move $a0, $s3
    jal  int_to_str_buf
    move $a0, $s1
    la   $a1, num_buf
    move $a2, $v0
    li   $v0, 15
    syscall
    
    move $a0, $s1
    la   $a1, dot_sign
    li   $a2, 1
    li   $v0, 15
    syscall
    
    addi $s2, $s2, 48
    sb   $s2, num_buf
    move $a0, $s1
    la   $a1, num_buf
    li   $a2, 1
    li   $v0, 15
    syscall
    
    lw   $ra, 16($sp)
    lw   $s0, 12($sp)
    lw   $s1, 8($sp)
    lw   $s2, 4($sp)
    lw   $s3, 0($sp)
    addi $sp, $sp, 20
    jr   $ra

int_to_str_buf:
    move $t0, $a0
    beq  $t0, $zero, int_zero
    
    la   $t1, num_buf
    addi $t1, $t1, 15
    li   $t2, 0
    
int_loop:
    beq  $t0, $zero, int_reverse
    li   $t3, 10
    div  $t0, $t3
    mflo $t0
    mfhi $t4
    addi $t4, $t4, 48
    sb   $t4, 0($t1)
    addi $t1, $t1, -1
    addi $t2, $t2, 1
    j    int_loop
    
int_reverse:
    addi $t1, $t1, 1
    la   $t3, num_buf
    move $t4, $t2
int_copy:
    beq  $t4, $zero, int_done
    lb   $t5, 0($t1)
    sb   $t5, 0($t3)
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    addi $t4, $t4, -1
    j    int_copy
    
int_done:
    move $v0, $t2
    jr   $ra
    
int_zero:
    li   $t1, 48
    sb   $t1, num_buf
    li   $v0, 1
    jr   $ra