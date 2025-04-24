
#############################################################
# THIS PROGRAM EXECUTES MULTIPLICATION VIA RECURSIVE ADDITION
#############################################################
    .data
result: .word 0
arga:   .word 5
argb:   .word 3

    .text
    .globl _start

_start:
    # Load the values of a and b from memory
    la s0, arga          # 
    lw s0, 0(s0)         # a = 5
    la s1, argb          # 
    lw s1, 0(s1)         # b = 3

    # Call the multiply function
    mv a0, s0 # a0 = s0
    mv a1, s1 # a1 = s1
    jal multiply

    # Store the result in memory (optional, for checking)
    la t0, result
    sw a0, 0(t0)     # Store the value in result
    
    #NOW PRINT THE RESULT
    #a0 = mult (a, b)
    #a1 = a
    #a2 = b
    mv a1, s0
    mv a2, s1
    jal print_result
    # Exit the program
    li a0, 10         # Exit code for ecall
    ecall

########################################
#ALGORITHM
#  multiply(a,b):
#    if b == 0:
#      return 0
#    else:
#      return a + multiply(a, b-1)
######################################
multiply:
    # Save the current state on the stack
    addi sp, sp, -8     # Push 2 words on stack
    sw a0, 4(sp)        # Save a 
    sw ra, 0(sp)        # Save ra

    # Base case: b == 0
    bne a1, zero, recursive_case
    li   a0, 0          # Return 0
    addi sp, sp, 8      # Pop the stack
    jr   ra

recursive_case:
    # Recursive case: result += a, b--
    addi a1, a1, -1
     # Call the multiply function
    jal multiply        # Recursive call mult(a, b-1)

    lw t0, 4(sp)        # Load the address of result into t0
    add a0, a0, t0      # result in a0 = a + mult(a, b-1)

    #Get ready to return from recursive call
    lw ra, 0(sp)        # Restore ra
    addi sp, sp, 8      # Pop stack
    jr ra

#LETS HANDLE OUTPUT
.data
    prompt:   .asciiz "The result of "
    times:    .asciiz " * "
    equals:   .asciiz " = "
    new_line: .asciiz "\n"

.text

#the result will be in the a0 register
#print results takes 3 arguments a0 = a, a1 = b, a2 = result
#this should give you appreciation for printf in C
print_result:
    #save a0 & a1 they are needed for syscalls
    mv t0, a0
    mv t1, a1

    #print the prompt
    li a0, 4        # 4 is syscall for print_str
    la a1, prompt
    ecall

    # Print arg 1 which is now in t0
    li a0, 1        # 1 is syscall for print_int
    mv a1, t1
    ecall

    #print the multiply symbox
    li a0, 4        # 4 is syscall for print_str
    la a1, times
    ecall

    # Print arg 2 which is in a2
    li a0, 1        # 1 is syscall for print_int
    mv a1, a2
    ecall

    #print the multiply symbox
    li a0, 4        # 4 is syscall for print_str
    la a1, equals
    ecall

    # Print the result
    li a0, 1        # 1 is syscall for print_int
    mv a1, t0
    ecall

    # Print a newline
    li a0, 4
    la a1, new_line
    ecall

    jr ra
