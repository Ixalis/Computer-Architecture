.data
    input_file:     .asciiz "E:/School/CA/LAB/LAB/Lab3/raw_input.txt"
    output_file:    .asciiz "E:/School/CA/LAB/LAB/Lab3/formatted_result.txt"
    
    header:         .asciiz "-----Student personal information-----\n"
    name_label:     .asciiz "Name: "
    id_label:       .asciiz "ID: "
    address_label:  .asciiz "Address: "
    age_label:      .asciiz "Age: "
    religion_label: .asciiz "Religion: "
    newline:        .asciiz "\n"
    
.text
.globl main

main:
    # Allocate memory dynamically for buffer (256 bytes)
    li $v0, 9
    li $a0, 256
    syscall
    move $s0, $v0               # $s0 = pointer to allocated buffer
    
    # Initialize buffer with zeros
    move $t0, $s0
    li $t1, 256
init_buffer:
    beqz $t1, init_done
    sb $zero, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, -1
    j init_buffer
init_done:
    
    # Open input file for reading
    li $v0, 13
    la $a0, input_file
    li $a1, 0                   # Read mode
    li $a2, 0
    syscall
    move $s1, $v0               # $s1 = input file descriptor
    
    # Check if file opened successfully
    bltz $s1, exit              # If fd < 0, exit
    
    # Read from input file
    li $v0, 14
    move $a0, $s1               # File descriptor
    move $a1, $s0               # Buffer address
    li $a2, 255                 # Max bytes to read
    syscall
    move $s2, $v0               # $s2 = number of bytes read
    
    # Close input file
    li $v0, 16
    move $a0, $s1
    syscall
    
    # Allocate memory for each field (5 fields, 100 bytes each)
    li $v0, 9
    li $a0, 100
    syscall
    move $s3, $v0               # $s3 = name
    
    li $v0, 9
    li $a0, 100
    syscall
    move $s4, $v0               # $s4 = id
    
    li $v0, 9
    li $a0, 100
    syscall
    move $s5, $v0               # $s5 = address
    
    li $v0, 9
    li $a0, 100
    syscall
    move $s6, $v0               # $s6 = age
    
    li $v0, 9
    li $a0, 100
    syscall
    move $s7, $v0               # $s7 = religion
    
    # Initialize all field buffers
    move $a0, $s3
    jal clear_buffer
    move $a0, $s4
    jal clear_buffer
    move $a0, $s5
    jal clear_buffer
    move $a0, $s6
    jal clear_buffer
    move $a0, $s7
    jal clear_buffer
    
    # Start parsing from beginning of buffer
    move $t0, $s0               # Current position in buffer
    
    # Skip leading whitespace
skip_whitespace:
    lb $t1, 0($t0)
    beq $t1, 32, skip_space     # space
    beq $t1, 9, skip_space      # tab
    beq $t1, 10, skip_space     # newline
    beq $t1, 13, skip_space     # carriage return
    j parse_fields
skip_space:
    addi $t0, $t0, 1
    j skip_whitespace
    
parse_fields:
    # Parse field 1: Name
    move $a0, $t0               # Source
    move $a1, $s3               # Destination (name)
    jal extract_field
    move $t0, $v0               # Update current position
    
    # Parse field 2: ID
    move $a0, $t0
    move $a1, $s4               # Destination (id)
    jal extract_field
    move $t0, $v0
    
    # Parse field 3: Address
    move $a0, $t0
    move $a1, $s5               # Destination (address)
    jal extract_field
    move $t0, $v0
    
    # Parse field 4: Age
    move $a0, $t0
    move $a1, $s6               # Destination (age)
    jal extract_field
    move $t0, $v0
    
    # Parse field 5: Religion (last field)
    move $a0, $t0
    move $a1, $s7               # Destination (religion)
    jal extract_last_field
    
    # Print to terminal
    jal print_to_terminal
    
    # Write to output file
    jal write_to_file
    
    j exit

# Function: clear_buffer
# $a0 = buffer address
clear_buffer:
    move $t0, $a0
    li $t1, 100
clear_loop:
    beqz $t1, clear_done
    sb $zero, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, -1
    j clear_loop
clear_done:
    jr $ra

# Function: extract_field
# Extracts text until comma
# $a0 = source address, $a1 = destination address
# Returns: $v0 = address after comma
extract_field:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $t1, $a0               # Source pointer
    move $t2, $a1               # Destination pointer
    
extract_loop:
    lb $t3, 0($t1)              # Load byte
    beqz $t3, extract_done      # If null, done
    beq $t3, 44, extract_done   # If comma (ASCII 44), done
    beq $t3, 10, extract_done   # If newline, done
    beq $t3, 13, extract_done   # If carriage return, done
    
    sb $t3, 0($t2)              # Store byte
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j extract_loop
    
extract_done:
    sb $zero, 0($t2)            # Null terminate
    
    # Skip the comma if present
    lb $t3, 0($t1)
    bne $t3, 44, extract_return
    addi $t1, $t1, 1
    
extract_return:
    move $v0, $t1               # Return position after comma
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Function: extract_last_field
# Extracts text until newline or null
# $a0 = source address, $a1 = destination address
extract_last_field:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $t1, $a0
    move $t2, $a1
    
extract_last_loop:
    lb $t3, 0($t1)
    beqz $t3, extract_last_done      # If null, done
    beq $t3, 10, extract_last_done   # If newline (ASCII 10), done
    beq $t3, 13, extract_last_done   # If carriage return (ASCII 13), done
    
    sb $t3, 0($t2)
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j extract_last_loop
    
extract_last_done:
    sb $zero, 0($t2)            # Null terminate
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Function: print_to_terminal
print_to_terminal:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Print header
    li $v0, 4
    la $a0, header
    syscall
    
    # Print Name
    li $v0, 4
    la $a0, name_label
    syscall
    move $a0, $s3
    syscall
    la $a0, newline
    syscall
    
    # Print ID
    li $v0, 4
    la $a0, id_label
    syscall
    move $a0, $s4
    syscall
    la $a0, newline
    syscall
    
    # Print Address
    li $v0, 4
    la $a0, address_label
    syscall
    move $a0, $s5
    syscall
    la $a0, newline
    syscall
    
    # Print Age
    li $v0, 4
    la $a0, age_label
    syscall
    move $a0, $s6
    syscall
    la $a0, newline
    syscall
    
    # Print Religion
    li $v0, 4
    la $a0, religion_label
    syscall
    move $a0, $s7
    syscall
    la $a0, newline
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Function: write_to_file
write_to_file:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Open output file for writing
    li $v0, 13
    la $a0, output_file
    li $a1, 1                   # Write mode
    li $a2, 0
    syscall
    move $t9, $v0               # $t9 = file descriptor
    
    bltz $t9, write_done        # If error, skip
    
    # Write header
    li $v0, 15
    move $a0, $t9
    la $a1, header
    li $a2, 39                  # Length of header
    syscall
    
    # Write "Name: "
    li $v0, 15
    move $a0, $t9
    la $a1, name_label
    li $a2, 6
    syscall
    
    # Write name value
    move $a1, $s3
    jal get_string_length
    li $v0, 15
    move $a0, $t9
    move $a1, $s3
    move $a2, $v1
    syscall
    
    # Write newline
    li $v0, 15
    move $a0, $t9
    la $a1, newline
    li $a2, 1
    syscall
    
    # Write "ID: "
    li $v0, 15
    move $a0, $t9
    la $a1, id_label
    li $a2, 4
    syscall
    
    # Write ID value
    move $a1, $s4
    jal get_string_length
    li $v0, 15
    move $a0, $t9
    move $a1, $s4
    move $a2, $v1
    syscall
    
    # Write newline
    li $v0, 15
    move $a0, $t9
    la $a1, newline
    li $a2, 1
    syscall
    
    # Write "Address: "
    li $v0, 15
    move $a0, $t9
    la $a1, address_label
    li $a2, 9
    syscall
    
    # Write address value
    move $a1, $s5
    jal get_string_length
    li $v0, 15
    move $a0, $t9
    move $a1, $s5
    move $a2, $v1
    syscall
    
    # Write newline
    li $v0, 15
    move $a0, $t9
    la $a1, newline
    li $a2, 1
    syscall
    
    # Write "Age: "
    li $v0, 15
    move $a0, $t9
    la $a1, age_label
    li $a2, 5
    syscall
    
    # Write age value
    move $a1, $s6
    jal get_string_length
    li $v0, 15
    move $a0, $t9
    move $a1, $s6
    move $a2, $v1
    syscall
    
    # Write newline
    li $v0, 15
    move $a0, $t9
    la $a1, newline
    li $a2, 1
    syscall
    
    # Write "Religion: "
    li $v0, 15
    move $a0, $t9
    la $a1, religion_label
    li $a2, 10
    syscall
    
    # Write religion value
    move $a1, $s7
    jal get_string_length
    li $v0, 15
    move $a0, $t9
    move $a1, $s7
    move $a2, $v1
    syscall
    
    # Write newline
    li $v0, 15
    move $a0, $t9
    la $a1, newline
    li $a2, 1
    syscall
    
    # Close output file
    li $v0, 16
    move $a0, $t9
    syscall
    
write_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Function: get_string_length
# $a1 = string address
# Returns: $v1 = length
get_string_length:
    move $t1, $a1
    li $v1, 0
    
strlen_loop:
    lb $t2, 0($t1)
    beqz $t2, strlen_done
    addi $v1, $v1, 1
    addi $t1, $t1, 1
    j strlen_loop
    
strlen_done:
    jr $ra

exit:
    li $v0, 10
    syscall