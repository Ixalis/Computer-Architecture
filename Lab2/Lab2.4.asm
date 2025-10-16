        .eqv N 10
        .eqv BUFSZ 256

.data
prompt_line:   .asciiz "Enter 10 integers separated by spaces (or commas):\n"
need10_err:    .asciiz "Error: fewer than 10 integers provided.\n"
result_head:   .asciiz "Second largest value is "
found_in:      .asciiz ", found in index "
comma_space:   .asciiz ", "
newline:       .asciiz "\n"

buf:           .space BUFSZ
.align 2
arr:           .space 40             # 10 words

.text
.globl main
main:
    # Prompt and read a full line
    li      $v0, 4
    la      $a0, prompt_line
    syscall

    li      $v0, 8                   # read_string
    la      $a0, buf
    li      $a1, BUFSZ
    syscall

    # Parse the line into up to N integers
    la      $t0, buf                 # t0 = ptr
    la      $t1, arr                 # t1 = &arr[0]
    li      $t2, 0                   # val = 0
    li      $t3, 1                   # sign = +1
    li      $t4, 0                   # in_number flag (0=no, 1=started)
    li      $t5, 0                   # count = 0
    li      $t6, 0                   # digit_count in current token

parse_loop:
    lbu     $t7, 0($t0)              # ch
    beq     $t7, $zero, parse_eol    # end of string?

    li      $t8, 45                  # '-'
    bne     $t7, $t8, not_minus
    bne     $t4, $zero, not_minus    # already in number -> treat as delimiter
    li      $t3, -1
    li      $t4, 1                   # started number (sign seen)
    j       adv_char

not_minus:
    # Digit?
    li      $t8, 48                  # '0'
    slt     $t9, $t7, $t8
    bne     $t9, $zero, not_digit
    li      $t8, 57                  # '9'
    slt     $t9, $t8, $t7
    bne     $t9, $zero, not_digit
    # It's a digit
    beq     $t4, $zero, start_number
cont_number:
    # val = val*10 + digit
    sll     $t9, $t2, 3              # *8
    sll     $t8, $t2, 1              # *2
    addu    $t2, $t9, $t8            # *10
    addiu   $t7, $t7, -48            # digit value
    addu    $t2, $t2, $t7
    addiu   $t6, $t6, 1              # digit_count++
    j       adv_char

start_number:
    li      $t4, 1                   # started
    li      $t3, 1                   # reset sign to + in case no '-'
    li      $t2, 0
    li      $t6, 0
    j       cont_number

not_digit:
    beq     $t4, $zero, adv_char
    beq     $t6, $zero, reset_token  
finalize_token:
    blt     $t5, N, store_token
    j       adv_char                 # ignore extra numbers beyond N

store_token:
    bltz    $t3, negate_val
    j       have_final_val
negate_val:
    subu    $t2, $zero, $t2
have_final_val:
    sw      $t2, 0($t1)
    addiu   $t1, $t1, 4
    addiu   $t5, $t5, 1              # count++

reset_token:
    li      $t2, 0
    li      $t3, 1
    li      $t4, 0
    li      $t6, 0
    # fall through to adv_char

adv_char:
    addiu   $t0, $t0, 1
    j       parse_loop

parse_eol:
    # End of string: if mid-number with digits, finalize
    beq     $t4, $zero, parsed_done
    beq     $t6, $zero, parsed_done  # no digits -> ignore
    blt     $t5, N, store_token_eol
    j       parsed_done
store_token_eol:
    bltz    $t3, negate_val_eol
    j       have_final_val_eol
negate_val_eol:
    subu    $t2, $zero, $t2
have_final_val_eol:
    sw      $t2, 0($t1)
    addiu   $t1, $t1, 4
    addiu   $t5, $t5, 1

parsed_done:
    # Check that we got N integers
    li      $t8, N
    beq     $t5, $t8, have_10
    li      $v0, 4
    la      $a0, need10_err
    syscall
    j       exit_prog

have_10:
    # Second-largest distinct search
    la      $t1, arr
    lw      $t2, 0($t1)             # max1
    li      $t3, 0x80000000         # max2 = INT_MIN
    li      $t0, 0                  # i = 0

scan_loop:
    bge     $t0, N, scan_done
    lw      $t4, 0($t1)             # x

    # if x > max1: max2 = max1; max1 = x
    slt     $t6, $t2, $t4
    beq     $t6, $zero, not_new_max
    move    $t3, $t2
    move    $t2, $t4
    j       next_i

not_new_max:
    # else if x < max1 and x > max2: max2 = x
    beq     $t4, $t2, next_i
    slt     $t6, $t4, $t2           # x < max1?
    beq     $t6, $zero, next_i
    slt     $t6, $t3, $t4           # max2 < x?
    beq     $t6, $zero, next_i
    move    $t3, $t4

next_i:
    addiu   $t1, $t1, 4
    addiu   $t0, $t0, 1
    j       scan_loop

scan_done:
    li      $t6, 0x80000000
    bne     $t3, $t6, have_second
    # No second largest distinct value
    li      $v0, 4
    la      $a0, need10_err         # reuse or replace with a nicer message
    syscall
    j       exit_prog

have_second:
    # Print header and value
    li      $v0, 4
    la      $a0, result_head
    syscall
    li      $v0, 1
    move    $a0, $t3
    syscall

    # Print "found in index " and list indices
    li      $v0, 4
    la      $a0, found_in
    syscall

    la      $t1, arr
    li      $t0, 0                   # i = 0
    li      $t6, 0                   # printed_any = 0

print_idx_loop:
    bge     $t0, N, done_print_idx
    lw      $t4, 0($t1)
    bne     $t4, $t3, skip_idx

    beq     $t6, $zero, first_idx
    li      $v0, 4
    la      $a0, comma_space
    syscall
first_idx:
    li      $v0, 1
    move    $a0, $t0
    syscall
    li      $t6, 1

skip_idx:
    addiu   $t0, $t0, 1
    addiu   $t1, $t1, 4
    j       print_idx_loop

done_print_idx:
    li      $v0, 4
    la      $a0, newline
    syscall

exit_prog:
    li      $v0, 10
    syscall
