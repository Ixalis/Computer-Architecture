.data
prompt:     .asciiz "Please input element "
colon:      .asciiz ": "
indexMsg:   .asciiz "\nPlease enter index: "
resultMsg:  .asciiz "\nValue = "
newline:    .asciiz "\n"

.align 2               # <-- ensure next label is 4-byte aligned
array:      .space 20  # 5 * 4 bytes

.text
.globl main
main:
    la   $t0, array           # base address of array
    li   $t1, 0               # i = 0

input_loop:
    bge  $t1, 5, input_done   # if i >= 5, exit loop

    # print "Please input element "
    li   $v0, 4
    la   $a0, prompt
    syscall

    # print i
    move $a0, $t1
    li   $v0, 1
    syscall

    # print ": "
    li   $v0, 4
    la   $a0, colon
    syscall

    # read integer
    li   $v0, 5
    syscall

    # store integer in array[i]
    sw   $v0, 0($t0)

    # move to next element
    addi $t0, $t0, 4
    addi $t1, $t1, 1
    j    input_loop

input_done:
    # ask for index
    li   $v0, 4
    la   $a0, indexMsg
    syscall

    # read index
    li   $v0, 5
    syscall
    move $t2, $v0              # t2 = index

    # calculate address of array[index]
    la   $t0, array
    sll  $t3, $t2, 2           # multiply index by 4
    add  $t0, $t0, $t3

    lw   $t4, 0($t0)           # load value

    # print result
    li   $v0, 4
    la   $a0, resultMsg
    syscall

    move $a0, $t4
    li   $v0, 1
    syscall

    # print newline
    li   $v0, 4
    la   $a0, newline
    syscall

    # exit
    li   $v0, 10
    syscall
