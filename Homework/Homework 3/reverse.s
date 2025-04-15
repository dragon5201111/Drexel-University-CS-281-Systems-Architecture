.data      
    A : .word 5, 4, 3, 2, 1, 10, 9, 8, 7, 6     
    newline: .asciiz "\n"     
    space: .asciiz " "          
    .equ sz_A, 10  

.text                
    .globl  main

main:
    # Print before reversing
    la a0, A
    li a1, sz_A
    jal print_array

    la a0, A
    li a1, sz_A
    jal reverse

    # Print after reverse
    la a0, A
    li a1, sz_A
    jal print_array
    
    # Exit the program
    li a0, 10 # Exit code for ecall     
    ecall 

print_array:
    mv t0, zero # t0 = loop counter i = 0
    mv t3, a0 # t3 = current array pointer = base address

print_array_loop:
    bge t0, a1, print_array_end_newline # if i >= count, go to print newline

    lw t1, 0(t3) # Load A[i]

    # Print number
    mv t5, a1 # Save original count (a1) because syscall uses a1
    li a0, 1 # Syscall for print integer
    mv a1, t1 # Argument: value to print (from t1)
    ecall

    # Print space
    li a0, 4 # Syscall for print string
    la a1, space # Address of space string
    ecall

    # Prepare for next iteration
    mv a1, t5 # Restore original count into a1
    addi t3, t3, 4  # Increment current array pointer (t3 += 4)
    addi t0, t0, 1  # Increment loop counter i (t0 += 1)
    j print_array_loop

print_array_end_newline:
    # Print newline
    li a0, 4
    la a1, newline # Address of newline string
    ecall
    jr ra # Return to caller

reverse:
    addi sp, sp -4 # Make space for ra
    sw ra, 0(sp) # Save ra on stack

    addi t0, zero, 0 # t0 = 0; this is index of start of A
    addi a1, a1, -1 # a1 -= 1; this is end of array
    jal reverse_loop

reverse_loop:
    bge t0, a1, reverse_finish # t0 >= a1
    
    jal swap

    addi t0, t0, 1 # t0 += 1; i++
    addi a1, a1, -1 # a1 -= 1; end--
    j reverse_loop

reverse_finish:
    lw ra, 0(sp) # Restore ra from stack
    addi sp, sp 4 # Restore stack
    jr ra # Jump to ra

swap:
    # Swap A[i] with A[end - i - 1]

    # Offset from base address
    slli t1, t0, 2 # t1 = t0 * 4
    slli t2, a1, 2 # t2 = a1 * 4
    
    add t1, a0, t1 # t1 = &A[a0] + t1
    add t2, a0, t2 # t2 = &A[a0] + t2

    lw a2, 0(t1) # a2 = value at address t1
    lw a3, 0(t2) # a3 = value at address t2

    # Do the swap
    sw a3, 0(t1) # Store a3 in at address in t1
    sw a2, 0(t2) # Store a2 in at address in t2 

    # Jump to caller
    jr ra

