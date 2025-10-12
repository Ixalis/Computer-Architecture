.data
input:  .asciiz "Please enter a positive integer less than 16: "
out:    .asciiz "Its binary form is: "
err_hi: .asciiz "error input higher than or equal to 16\n"
err_lo: .asciiz "error input lower than 0\n"

.text
.globl main
main:
    # --- prompt ---
    li   $v0, 4
    la   $a0, input
    syscall

    # --- read integer ---
    li   $v0, 5
    syscall
    move $t0, $v0          # store input in $t0

    # --- check if input >= 16 ---
    slti $t5, $t0, 16      # $t5 = 1 if $t0 < 16
    beq  $t5, $zero, error_high

    # --- check if input < 0 ---
    bgez $t0, ok           # if $t0 >= 0 jump to ok
    j    error_low

error_high:
    li   $v0, 4
    la   $a0, err_hi
    syscall
    li   $v0, 10
    syscall

error_low:
    li   $v0, 4
    la   $a0, err_lo
    syscall
    li   $v0, 10
    syscall

ok:
    # --- initialize registers for conversion ---
    li   $t1, 1
    li   $t2, 2
    li   $t3, 0
    li   $t7, 10
    j    loop

loop:
    bne  $t0, $zero, loop1
    j    print

loop1:
    div  $t0, $t2
    mfhi $t4
    mflo $t0

    mul  $t4, $t4, $t1      # tem = tem * t1
    mul  $t1, $t1, $t7      # t1 *= 10
    add  $t3, $t3, $t4
    j    loop

print:
    li   $v0, 4
    la   $a0, out
    syscall

    move $a0, $t3
    li   $v0, 1
    syscall

    # --- exit ---
    li   $v0, 10
    syscall
