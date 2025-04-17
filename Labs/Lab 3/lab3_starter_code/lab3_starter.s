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
mv a0,s0
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

``` #you can change this, but in my implmentation I saved s0 and ra on the stack
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
        #TO DO - write the code to decrement the counter.  Note that this has
        #to take into account the edge condition where the counter is at 0. There
        #is a MIN_VAL constnt that you can use.  If the counter is at 0, do not
        #decrement it, but instead jump to error_counter. If its not at zero decrement
        #the counter and use write_lcd to update the display. 
        jal write_lcd
        j exit_adj_counter

    inc_counter:
        #TODO - do the same thing for incrementing the counter.  This time you will
        #need to check if the counter is at the MAX_VAL.
        jal write_lcd
        j exit_adj_counter
    

    err_counter:
        # if we get an error, like at teh boundry condition, flash the LEDs twice. 
        # remember we have a sample program that shows how to do this
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

    #write the code to update the LCD here. Use the count_to_100 sample as
    #guidence

    #restore the stack
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

#TODO - to implement write_lcd you might want to consider adding a few functions
#here as helpers to keep your code clean.


flash_led:
   #see the sample code for this function 
   ret

#you might find it helpful to include the sleep helper I have been using
#in my sample code. 
sleep:
    mv t0, a0
    sleep_loop:
        addi t0, t0, -1  # Decrement counter
        bnez t0, sleep_loop  # Continue loop if t0 is not zero
ret