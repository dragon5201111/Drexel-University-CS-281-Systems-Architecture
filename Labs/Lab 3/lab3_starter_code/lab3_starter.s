#Starter template for lab 3
.data
                   #76543210
    digits: .word 0b00111111,   # 0
            .word 0b00000110,   # 1   
            .word 0b01011011,   # 2
            .word 0b01001111,   # 3
            .word 0b01100110,   # 4
            .word 0b01101101,   # 5
            .word 0b01111101,   # 6
            .word 0b00000111,   # 7
            .word 0b01111111,   # 8
            .word 0b01100111    # 9
     digit_msk : .word 0b111111111111111
     digit_max : .word 100
     digits_sz : .word 10

.text   
# some useful constants that you might want to use in your program to improve
#readability    
.equ LEFT_PRESS, 0b10
.equ RIGHT_PRESS, 0b01
.equ NO_PRESS, 0b00

.equ MIN_VAL, 0
.equ MAX_VAL, 99    
	.globl  main 

main:

#start by initializing the LCD, write 0 to the display
li s0, 0
mv a0, s0
jal write_lcd

#this is the main loop that will run forever
loop:
    #we will be using register s0 to hold the current counter value
    #the adjust_counter function will render the next value and return
    #it in a0.  Note the adjusted value will be INCREMENTED if the
    #left button is pressed, and DECREMENTED if the right button is
    #pressed. Note that we start by getting the current state of the
    #pushbutton by making ecall 0x122.
    li a0, 0x122
    ecall
    mv a1, s0
    jal adjust_counter   #adjust_counter(button_state, current_counter)
    mv s0, a0
j loop
  
    ret #you will never get here but its god practice

#this function accepts the state of the buttons in a0, and the current counter 
#value in a1 and will adjust it based on the button press state.  
adjust_counter:
    addi sp, sp, -8
    sw s0, 4(sp)
    sw ra, 0(sp)

    #STEP 1, take the appropriate action based on the button press
    mv s0, a1 #hold the current counter in s0
    li t0, NO_PRESS
    beq a0, t0, exit_adj_counter
    li t0, LEFT_PRESS
    beq a0, t0, dec_counter
    li t0, RIGHT_PRESS
    beq a0, t0, inc_counter
    j err_counter

    dec_counter:
        # Load min value
        li t0, MIN_VAL
        # Current counter value == MIN_VAL, jump to err_counter
        beq s0, t0, err_counter
        # Decrement counter value
        addi s0, s0, -1
        # Prep arg for write_lcd
        mv a0, s0

        jal write_lcd
        j exit_adj_counter

    inc_counter:
         # Load max value
        li t0, MAX_VAL
        # Current counter value == MAX_VAL, jump to err_counter
        beq s0, t0, err_counter
        # Increment counter value
        addi s0, s0, 1
        # Prep arg for write_lcd
        mv a0, s0

        jal write_lcd
        j exit_adj_counter
    

    err_counter:
        # Set flash count
        li a0, 5
        jal flash_led

#we are done restore the stack properly and return the next counter state in
#register a0   
exit_adj_counter:
    mv a0, s0
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 4
    ret

#This function writes the counter value passed in register a0 to the LCD
write_lcd:
    #setup stack, again you can change this if you want. 
    addi sp, sp, -4
    sw ra, 0(sp)

    
    jal extract_bcd #a0 = 10's place, a1 = 1's place
    jal encode_digit #a0 = encoded for 7 segment display
    mv a1,a0    #a1 = argument for 7 seg display update

    la t0, digit_msk
    lw a2, 0(t0)

    li a0, 0x120
    ecall

    #restore the stack
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

#TODO - to implement write_lcd you might want to consider adding a few functions
#here as helpers to keep your code clean.


flash_led:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    li s0, 0
    mv s1, a0
flash_loop:
    beq s0, s1, flash_done
    addi s0, s0, 1 #update counter

    #turn on both LEDs
    li a0, 0x121
    li a1, 0b11
    ecall
    #wait a little
    li a0, 250
    jal sleep

    #turn off both LEDs
    li a0, 0x121
    li a1, 0b00
    ecall

     #wait a little
    li a0, 250
    jal sleep

    j flash_loop

flash_done:
    # Restore values
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

#you might find it helpful to include the sleep helper I have been using
#in my sample code. 
sleep:
    mv t0, a0
    sleep_loop:
        addi t0, t0, -1  # Decrement counter
        bnez t0, sleep_loop  # Continue loop if t0 is not zero
ret

#accepts a number and returns the bitfield for the 
#seven segment display
extract_bcd:
    # Load the input number from a0
    mv t0, a0           # t0 = input number

    # Extract the 10's place by dividing by 10
    li t1, 10           # t1 = 10
    div t2, t0, t1      # t2 = t0 / 10 (10's place)
    rem t3, t0, t1      # t3 = t0 % 10 (1's place)

    # Store the results in a0 and a1
    mv a0, t2           # a0 = 10's place
    mv a1, t3           # a1 = 1's place

    # Return from the function
    ret

encode_digit:
    # Load the input 10s place from a0
    
    # Calculate the address of the digit table
    la t0, digits       # t1 = &digits[0]

    # Calculate the offset for the digit table
    # ex: a0 = 2 = 0b10, 0b10 << 2 = 1000 = 8 
    slli a0, a0, 2      # Table offset for 10's place
    slli a1, a1, 2      # Table offset for 1's place

    add t1, t0, a0      # address of 10's place digit
    add t2, t0, a1      # address of 1's place digit
    lw a0, 0(t1)        # a0 = 10's place digit
    lw a1, 0(t2)        # a1 = 1's place digit

    # Combine the 10's and 1's place digits
    slli a0, a0, 8      # Shift 10's place to the left
    or a0, a0, a1       # Combine 10's and 1's place

    #a0 now has the bitfield for the seven segment display
    # [ digit 10's place ][ digit 1's place ]
    ret