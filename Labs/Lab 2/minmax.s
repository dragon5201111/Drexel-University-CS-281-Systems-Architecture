.data
    A : .word 5, 4, 3, 2, 1, 10, 9, 8, 7, 6
    sz_A : .word 10
    min : .word 0x7FFFFFFF #max signed value 2^31 - 1
    max : .word 0x80000000 #min signed value -2^31
    prompt_min: .asciiz "The minimum value in the array is: "
    prompt_max: .asciiz "The maximum value in the array is: "
    new_line: .asciiz "\n"
.text
    .globl main # assembly directive that makes the symbol main
    # global and this is where execution starts

main:
    la t0, A # Load address of first element         
    li t1, 0 # Loop counter  

    lw s1, sz_A # Load size of A          
    lw s2, min # Load min         
    lw s3, max # Load max       

main_loop:
    lw s4, 0(t0) # Load value of address at t0 into s4       

    blt s4, s2, update_min # s4 < s2; s4 < min
    bgt s4, s3, update_max # s4 > s3; s4 > max
    j continue_loop

update_min:
    mv s2, s4 # s2 = s4
    j main_loop

update_max:
    mv s3, s4 # s3 = s4
    j main_loop

continue_loop:
    addi t0, t0, 4 # Move to next element; calculate next element address
    addi t1, t1, 1 # t1 = t1 + 1
    blt t1, s1, main_loop # if t1 < s1, continue loop; if i < sz_A, continue loop

print_min_max:
    # Print min prompt
    li a0, 4
    la a1, prompt_min
    ecall

    # Print min
    li a0, 1
    mv a1, s2
    ecall
    
    # Print newline
    li a0, 4
    la a1, new_line
    ecall

    # Print max prompt
    la a1, prompt_max
    ecall

    # Print max
    li a0, 1 # 1 is syscall for print_int
    mv a1, s3
    ecall
    
    # Print newline
    li a0, 4
    la a1, new_line
    ecall

    # Exit
    li a0, 10 # Exit code for ecall
    ecall


    

    




