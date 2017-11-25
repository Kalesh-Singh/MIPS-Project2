.data
	user_input: .space 1001
	too_large:	.asciiz		"too large"
	nan:	.asciiz		"NaN"
	
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
            addi $s1, $zero, 0                  # Initialize the offset to 0
            Loop4:
                add $t0, $s0, $s1               # Increment the address of the user input
                lb $t1, 0($t0)                  # Get the current character
                beq $t1, 0, StartOfString       # If current char is end line char (0) --> StartOfString
                beq $t1, 10, StartOfString      # If current char is new line char (10) --> StartOfString
                addi $s1, $s1, 1                # Increment the offset
                j Loop4

            
            
            StartOfString:
                # addi $s1, $s1, -1               # Decrement the end index by 1
                # addi $a2, $zero, 0            # Initialize the start index to 0
                addi $a3, $zero, 0              # Innitialize the end parameter to the end index
            
            Loop5:
                # While $a3 <= $s1
                add $a2, $zero, $a3             # Initialize the start index to the end index
                
                Loop6:
                    # While the current char is either spaces or tabs or commas, print the char
                    # And increment both the start and end indices
                    beq $a2, $s1, Exit          # If the start index is equal to the end of string --> Exit
                    beq $a3, $s1, Continue      # If the end index is equal to the end of string --> Continue
                    
                    add $t0, $s0, $a3           # Get address of the current character
                    lb $a0, 0($t0)              # Get the current character
                    beq $a0, 9, PrintChar       # If the current char is a tab -- > PrintChar
                    beq $a0, 32, PrintChar      # If the current char is a space --> PrintChar
                    bne $a0, 44, Loop7          # If the current char is not a comma (,) --> Loop7

                    PrintChar:
                        li $v0, 11              # Print the current character
                        syscall
                    
                    # beq $a3, $s1, Continue      # If the end index is equal to the end of string --> Continue
                    addi $a2, $a2, 1            # Increment the start index
                    addi $a3, $a3, 1            # Increment the end index
                    # beq $a3, $s1, Continue      # If the end index is equal to the end of string --> Continue
                    j Loop6

                Loop7:
                    # While the end index is not a comma or NUL (0) or \n(10), increment the end index
                    add $t0, $s0, $a3           # Get the address of the char at the end index
                    lb $t1, 0($t0)              # Get the char at that address
                    beq $t1, 44, Loop8          # If the current char is a comma (,) --> Loop8
                    # beq $t1, 0, Continue        # If the current char is NUL --> Continue
                    # beq $t1, 10, Continue       # If the current char is '/n' --> Continue
                    # beq $a2, $s1, Exit          # If the start index is equal to the end of string --> Exit
                    beq $a3, $s1, Continue      # If the end index is equal to the end of string --> Continue
                    addi $a3, $a3, 1            # Increment the end index
                    j Loop7

                Loop8:
                    # While the current char is either space or tabs or commas, decrement the end index
                    add $t0, $s0, $a3           # Get address of the current character
                    lb $t1, 0($t0)              # Get the current character

                    beq $t1, 9, DecrementEndIndex           # If the current char is a tab -- > DecrementEndIndex
                    beq $t1, 32, DecrementEndIndex          # If the current char is a space --> DecrementEndIndex
                    bne $t1, 44, GetDecimalVal              # If the current char is not a comma (,) --> GetDecimalVal

                    DecrementEndIndex:
                        addi $a3, $a3, -1

                    j Loop8          

                GetDecimalVal:
                    sub $t0, $a3, $a2               # Get the difference between the start and end index
                    bgt $t0, 7, TooLarge            # If the difference is grreater than 7 --> TooLarge

                    jal subprogram_2                # Convert the hexadecimal number to a decimal number
                    jal subprogram_3                # Print the undigned decimal value of the result
                    
                    j Next                          # Go to the next iteration of the loop

                    TooLarge:
                        # Print too large 
                        li $v0, 4
                        la $a0, too_large
                        syscall
                        j Next

                    NotANumber:
                        # Print NaN
                        li $v0, 4
                        la $a0, nan
                        syscall
                        # No Need to jump to Next, it will fall through to next
                            
                Next:
                    beq $a3, $s1, Continue      # If the end index is equal to the end of string --> Continue
                    addi $a2, $a2, 1            # Increment the start index
                    addi $a3, $a3, 1            # Increment the end index
                
                    j Loop5

            Continue:
                addi $a3, $a3, -1               # Decrement the end index by 1
                Loop:
                    # While the current char is either space or tabs or commas, decrement the end index
                      add $t0, $s0, $a3           # Get address of the current character
                      lb $t1, 0($t0)              # Get the current character
  
  
                      beq $t1, 9, DecrementEndIndex2           # If the current char is a tab -- > DecrementEndIndex
                      beq $t1, 32, DecrementEndIndex2          # If the current char is a space --> DecrementEndIndex
                      bne $t1, 44, GetDecimalVal2              # If the current char is not a comma (,) --> GetDecimalVal
  
                      DecrementEndIndex2:
                          addi $a3, $a3, -1
  
                      j Loop
  
                  GetDecimalVal2:
                      sub $t0, $a3, $a2               # Get the difference between the start and end index
                      bgt $t0, 7, TooLarge2            # If the difference is grreater than 7 --> TooLarge
  
                      jal subprogram_2                # Convert the hexadecimal number to a decimal number
                      jal subprogram_3                # Print the undigned decimal value of the result
  
                      j Exit                          # Go to the next iteration of the loop
  
                      TooLarge2:
                          # Print too large
                          li $v0, 4
                          la $a0, too_large
                          syscall
                          j Exit
  
                      NotANumber2:
                          # Print NaN
                          li $v0, 4
                          la $a0, nan
                          syscall
                          # No Need to jump to Exit, it will fall through to exit
           
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
        bgt $t0, 'f', ReturnError	    # If the char is greater than 'f' --> ReturnError
        bge $t0, 'a', Return1                # If char is within a to f --> Return1
        addi $t1, $zero, 55                 # Change the reference point to 55
        bgt $t0, 'F', ReturnError	    # If the char is greater than 'F' --> ReturnError
        bge $t0, 'A', Return1                # If char is within A to F --> Return 1
        bgt $t0, '9', ReturnError	    # If the char is greater than '9' --> ReturnError
        blt $t0, '0', ReturnError	    # If the char is greater than '0' --> ReturnError
        addi $t1, $zero, 48                 # Change the reference point to 48
        
        Return1:
            sub $v1, $t0, $t1               # Subtract the refernce from the character value  		
            jr $ra                          # and return the result in $v1
        
        ReturnError:
        	j NotANumber
	
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
