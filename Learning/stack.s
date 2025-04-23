.text
main:
    jal func

    nop
    nop

    li a0, 10
    ecall


func:
    # Store ra on stack
    addi sp, sp, -4
    sw ra, 0(sp)

    jal func2
    # Restore ra from stack
    lw ra, 0(sp)
    addi sp, sp 4
    jr ra
    
func2:
    # Store ra on stack
    addi sp, sp, -4
    sw ra, 0(sp)

    jal func3
    # Restore ra from stack
    lw ra, 0(sp)
    addi sp, sp 4
    jr ra

func3:
    jr ra

