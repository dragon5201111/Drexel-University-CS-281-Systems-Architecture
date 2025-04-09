.text
.globl main

main:
    li t0, 5
    li t1, 5
    
    beq t0, t1, 8
    add t0, t0, t1
    beq t0, t1, -4

    li a0, 10
    ecall

