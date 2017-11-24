.data
	user_input: .space 9
.text
	Main:
            # Get input from user
            li $v0, 8
            la $a0, user_input
            li $a1, 9
            syscall
            
            # Get the address of where the input is stored
            la $s0, user_input

            # Get the hexadecimal character the user entered
            # lb $a2, 0($s0)

            # Loop through string to get the start and end indices
            addi $a2, $zero, 0
            addi $a3, $zero, 7

            jal subprogram_2                # Convert the hexadecimal number to a decimal number
            jal subprogram_3                # Print the undigned decimal value of the result
          
            
            Exit:
			    # Exits the program
			    li $v0, 10
			    syscall

	subprogram_1:
		# Subprogram that converts a hexadecimal character to a decimal integer
		# It will use $v1 to return the result and $a2 for the argument
        # a = 97
        # A = 65
        # 0 = 48

        add $t0, $zero, $a2                 # Copy the argument
        addi $t1, $zero, 87                 # Initialize the reference point to 87
        bge $t0, 97, Return1                # If char is within a to f --> Return1
        addi $t1, $zero, 55                 # Change the reference point to 55
        bge $t0, 65, Return1                # If char is within A to F --> Return 1
        addi $t1, $zero, 48                 # Change the reference point to 48
        
        Return1:
            sub $v1, $t0, $t1               # Subtract the refernce from the character value  		
            jr $ra                          # and return the result in $v1
	
    subprogram_2:
        # Subprogram that converts a hexadecimal string to a decimal integer
        # Arguments $a1 is the start of the string and $a2 is the end of the string
        # The result is returned via the stack
        
        # Save return address of the caller function to stack
        sw $ra, 0($sp) 
        
        # Copy the arguments
        add $t2, $zero, $a2
        add $t3, $zero, $a3
        
        # Initialize the result to zero
        addi $t4, $zero, 0
        
        Loop1:
            add $t5, $s0, $t2               # Go to the next character address in the string
            lb $a2, 0($t5)                  # Get the character at that address
            jal subprogram_1         	    # Get the decimal value of the character
            sll $t4, $t4, 4                 # Shift the result left by 4
            or $t4, $t4, $v1                # Or the decimal value of the character with the result
            beq $t2, $t3, Return2           # If the current index is the last --> Return2
            addi $t2, $t2, 1                # Increment the offset            
            j Loop1
        
        Return2:
            lw $ra, 0($sp)			        # Get the old return value
            sw $t4, 0($sp)                  # Store the result on the stack
            jr $ra    
    
    subprogram_3:
        # Prints an unsigned decimal integer.
        # The stack is used to pass parameters.
        # No values are returned
        
        lw $t0, 0($sp)                      # Get the argument from the stack        

        addi $t1, $zero, 10                 # Set the divisor to 10
        addi $t4, $zero, 0                  # Initialize a counter to 0

        Loop2:
            divu $t0, $t1                   # $t0 / $t1 --> Remainder in HIGH, Quotient in LOW
            mflo $t0                        # Set the new Dividend to be the Quotient
            mfhi $t2                        # Get the Remainder (digit)
            addi $t2, $t2, 48               # Convert the digit to its ASCII character code

            # Store the address of the stack pointer in $t3 and add the counter to it
            la $t3, ($sp)
            add $t3, $t3, $t4       

            sb $t2, 0($t3)                  # Store the least siginificant byte of the remainder on the stack at the address of $t3
            # If the Dividend is 0 --> Exit the loop to Loop3
            beq $t0, $zero, Loop3

            addi $t4, $t4, 1                # Increment the counter

            j Loop2

        Loop3:
            # Print the digits in the reverse order
            lb $a0, 0($t3)
            li $v0, 11
            syscall
            
            beq $t3, $sp, Return3           # If the address in $t3 == address in $sp --> Return3
            addi $t3, $t3, -1               # Decrement the addreess in $t3
            j Loop3        
        Return3:
            jr $ra	
