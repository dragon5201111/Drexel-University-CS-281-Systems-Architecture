# I completed the extra credit #3.

.data
    arga:   .word 2
    print_sys_str: .word 4
    print_sys_int: .word 1
    prompt:   .asciiz "The result of "
    equals:   .asciiz "! = "
    new_line: .asciiz "\n"

.text
.globl _start

_start:
    la s0, arga # s0 = address of arga
    lw s0, 0(s0) # s0 = value of arga

    mv a1, s0 # a1 = factorial to go up to

    jal factorial

    la a1, arga
    lw a1, 0(a1) # Load factorial count for printing
    jal print_factorial

    li a0, 10 # Syscall to exit program
    ecall

factorial:
    # Make space on stack
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a1, 4(sp)

    slti t0, a1, 2  # a1 < 2, you get t0 = 1. Otherwise, you get t0 = 0
    beq t0, zero, factorial_recur

    li a0, 1 # Return base case of 1
    addi sp, sp, 8
    jr ra

factorial_recur:
    addi a1, a1, -1 # a1 -= 1

    jal factorial

    lw t0, 4(sp)
    mul a0, a0, t0 # Do multiplication

    # Recurse
    lw ra, 0(sp)
    addi sp, sp, 8
    jr ra


print_factorial:
    la t0, print_sys_str # Load syscall number for printing string
    lw t0, 0(t0)

    la t1, print_sys_int # Load syscall number for printing integer 
    lw t1, 0(t1)

    mv t3, a0 # Save factorial product to be printed
    mv t4, a1 # Save factorial number to be printed

    # Print prompt
    mv a0, t0
    la a1, prompt
    ecall

    # Print factorial number e.g., 4!
    mv a0, t1
    mv a1, t4
    ecall

    # print " != "
    mv a0, t0
    la a1, equals
    ecall

    # Print factorial product
    mv a0, t1
    mv a1, t3
    ecall

    # Finally, print new line character
    mv a0, t0
    la a1, new_line
    ecall
    
    # Return to start
    jr ra