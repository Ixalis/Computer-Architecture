# MIPS (MARS/SPIM)
# Count each character in a user-input string.
# Print characters by ascending frequency, then ASCII for ties.

        .eqv BUFSZ 256          # no colon; equate must be NAME VALUE

.data
prompt:     .asciiz "Enter a string (max 255 chars): "
input_str:  .space  BUFSZ        # 256-byte input buffer
comma_sp:   .asciiz ", "
semi_sp:    .asciiz "; "
newline:    .asciiz "\n"

.align 2                         # ensure word alignment for freq[]
freq:       .space 1024          # 256 words (4 bytes each)

.text
.globl main
main:
    # Prompt
    li   $v0, 4
    la   $a0, prompt
    syscall

    # Read string
    li   $v0, 8
    la   $a0, input_str
    li   $a1, BUFSZ
    syscall

    # Zero freq[]
    la   $t0, freq
    li   $t1, 256
zero_loop:
    beq  $t1, $zero, zero_done
    sw   $zero, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    j    zero_loop
zero_done:

    # Count
    la   $t2, input_str
count_loop:
    lbu  $t3, 0($t2)
    beq  $t3, $zero, count_done      # end at null
    beq  $t3, 10, skip_char          # skip LF
    beq  $t3, 13, skip_char          # skip CR (for safety)

    la   $t4, freq
    sll  $t5, $t3, 2                 # index*4
    addu $t4, $t4, $t5
    lw   $t6, 0($t4)
    addiu $t6, $t6, 1
    sw   $t6, 0($t4)

skip_char:
    addiu $t2, $t2, 1
    j    count_loop
count_done:

    # Scan for unique count and max freq
    li   $t7, 0                      # max_freq
    li   $s0, 0                      # unique_count
    la   $t0, freq
    li   $t1, 256
scan_loop:
    beq  $t1, $zero, scan_done
    lw   $t6, 0($t0)
    beq  $t6, $zero, scan_next
    addiu $s0, $s0, 1
    slt  $t8, $t7, $t6
    beq  $t8, $zero, scan_next
    move $t7, $t6
scan_next:
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    j    scan_loop
scan_done:

    beq  $s0, $zero, just_newline

    # Print ascending by frequency, then ASCII
    move $s1, $s0                    # remaining items
    li   $s2, 1                      # current frequency

outer_freq_loop:
    slt  $t9, $t7, $s2               # if max_freq < cur_freq -> done
    bne  $t9, $zero, print_done

    li   $t1, 0                      # ch = 0
inner_char_loop:
    beq  $t1, 256, next_freq

    la   $t0, freq
    sll  $t5, $t1, 2
    addu $t0, $t0, $t5
    lw   $t6, 0($t0)
    bne  $t6, $s2, skip_print

    # print char
    li   $v0, 11
    move $a0, $t1
    syscall

    # print ", "
    li   $v0, 4
    la   $a0, comma_sp
    syscall

    # print count
    li   $v0, 1
    move $a0, $s2
    syscall

    # delimiter: "; " or newline if last
    addiu $s1, $s1, -1
    bgtz $s1, print_semi
    li   $v0, 4
    la   $a0, newline
    syscall
    j    after_print

print_semi:
    li   $v0, 4
    la   $a0, semi_sp
    syscall

after_print:
skip_print:
    addiu $t1, $t1, 1
    j    inner_char_loop

next_freq:
    addiu $s2, $s2, 1
    j    outer_freq_loop

print_done:
    j    exit_prog

just_newline:
    li   $v0, 4
    la   $a0, newline
    syscall

exit_prog:
    li   $v0, 10
    syscall
