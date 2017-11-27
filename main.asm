.data
	user_input: .space      1001
	too_large:  .asciiz		"too large"
	nan:	    .asciiz		"NaN"
	
.text
	Main:
            # Get input from user
            li $v0, 8
            la $a0, user_input
            li $a1, 1001
            syscall
            
            # Get the address of where the input is stored
            la $s0, user_input

            # Loop through the string to find the end index
            addi $a2, $zero, 0                  # Initialize the offsets to 0
	        addi $a3, $zero, 0          	
    
            Loop4:
		    # Loop through the string keeping a start ($a2) and end index ($a3) for every sub-string
                add $t0, $a3, $s0               # Increment the address of the user input
                lb $t1, 0($t0)                  # Get the current character
                beq $t1, 0, Convert             # If current char is endline char (0) --> Convert
                beq $t1, 10, Convert            # If current char is newline char (10) --> Convert
                bne $t1, 44, Increment         # If current char is NOT a coma --> Increment

                Convert:
                    jal subprogram_2                # Call subprogram 2
                    jal subprogram_3                # Call subprogram 3
                    j ResetStart                    # Jump to ResetStart

                NotANumber:
                    li $v0, 4                   # Print "NaN"
                    la $a0, nan
                    syscall
                
                ResetStart:
                    add $t0, $a3, $s0               # Increment the address of the user input
                    lb $t1, 0($t0)                  # Get the character at $a3
                    beq $t1, 44, PrintComma         # If char is comma --> PrintComma ; else --> Exit
                    j Exit

                    PrintComma:
                        addi $a2, $a3, 1            # Set the start index to the end index plus 1

                        addi $a0, $t1, 0            # Print the comma
                        li $v0, 11
                        syscall 

                Increment:
                    # Check if a3 is a /n or /0 and Exit---> IMPLEMENT THIS
                    addi $a3, $a3, 1            # Increment the End index
                    j Loop4

            Exit:
			    # Exits the program
			    li $v0, 10
			    syscall

	subprogram_1:

        add $t0, $zero, $a2                 # Copy the argument
        addi $t1, $zero, 87                 # Initialize the reference point to 87
        bgt $t0, 'f', NotANumber	        # If the char is greater than 'f' --> NotANumber
        bge $t0, 'a', Return1               # If char is within a to f --> Return1
        addi $t1, $zero, 55                 # Change the reference point to 55
        bgt $t0, 'F', NotANumber	        # If the char is greater than 'F' --> NotANumber
        bge $t0, 'A', Return1               # If char is within A to F --> Return 1
        bgt $t0, '9', NotANumber	        # If the char is greater than '9' --> NotANumber
        blt $t0, '0', NotANumber	        # If the char is greater than '0' --> NotANumber
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

        # DECREMENT $t3 by 1
        addi $t3, $t3, -1
        
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
