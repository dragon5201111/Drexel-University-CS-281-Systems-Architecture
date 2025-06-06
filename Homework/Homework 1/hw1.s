.text
.globl _start

_start:
    # Test code
    lui s2, 0
    lui s3, 0

    jal ra, nor
    jal ra, nand

    li a0, 10          # Set exit code to 0
    li a7, 0           # Set system call number for exit
    ecall              # make system call

# Part a.
nor:
    or s1, s2, s3               # Perform bitwise OR on registers s2 and s3, result in s1
    xori s1, s1, 0xFFFFFFFF     # XOR the value in s1 with 0xFFFFFFFF to flip all bits
    ret                         # Return from the function to ra

# Part b.
nand:
    and s1, s2, s3              # Perform bitwise AND on registers s2 and s3, result in s1
    xori s1, s1, 0xFFFFFFFF     # XOR the value in s1 with 0xFFFFFFFF to flip all bits
    ret                         # Return from the function to ra
