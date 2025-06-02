li a0, 5
jal test
nop
nop
mv s1, a0
li a0, 0
ecall

test:
    li a0, 3
    jr ra
