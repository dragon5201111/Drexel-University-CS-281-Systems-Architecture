.data
    A : .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    sum : .word 0

    prompt: .asciiz "The sum of the array is: "
    new_line: .asciiz "\n"
.text
    .globl main # assembly directive that makes the symbol main
 # global and this is where execution starts
main:
    la s0, A # s0 = &A[0]

    la t0, sum # Load address of sum into t0
    la t2, A # Load address of A into t2
    sub t2, t0, t2 # t2 = t0 - t2; Subtract &sum - &A; 
    srli s1, t2, 2 # s1 = t2 >> 2; Right shift t2 by two bits (i.e., divide by 4) and place result in s1

    li t0, 0 # t0 = 0 i will be the index
    # we will use t1 to store the current array element
    li t2, 0 # t2 = 0 sum will be stored here
    #for each array element we will be first calculating the
    #address using A[i] = &A + (i * 4)
sum_loop:
    lw t1, 0(s0) # Load word (value) from address in s0 into t1
    add t2, t2, t1 # Add the value in t1 into t2; t2 = t2 + t1
    addi t0, t0, 1 # Increment t0 by 1; t0 = t0 + 1
    addi s0, s0, 4 # Add offset of 4 to s0; calculate next address for array element; s0 = s0 + 4
    bne t0, s1, sum_loop # If t0 doesn't equal s1 (the element count), jump to sum_loop; if t0 != s1 -> jump to sum_loop

    #now save the total in sum variable which is in t2
    la t0, sum
    sw t2, 0(t0)
    #print the results
    #print the prompt
    li a0, 4 # 4 is syscall for print_str
    la a1, prompt
    ecall
    # Print the sum value
    la t1, sum
    lw t1, 0(t1)
    li a0, 1 # 1 is syscall for print_int
    mv a1, t1
    ecall
    #print the newline
    li a0, 4 # 4 is syscall for print_str
    la a1, new_line
    ecall
    #now exit
    li a0, 10 # Exit code for ecall
    ecall