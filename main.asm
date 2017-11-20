.data
	user_input: .space 2
.text
	Main:

            # Get input from user
            li $v0, 8
            la $a0, user_input
            li $a1, 2
            syscall
            
            # Get the address of where the input is stored
            la $s0, user_input

            # Get the hexadecimal character the user entered
            lb $a2, 0($s0)

            jal HexToDec

            # Print the decimal value of the character
            li $v0, 1
            add $a0, $zero, $v1
            syscall
            
            Exit:
			# Exits the program
			li $v0, 10
			syscall
	
	HexToDec:
		# Subprogram that converts a hexadecimal character to a decimal interger
		# It will use $v1 to return the result and $a2 for the argument
        # a = 97
        # A = 65
        # 0 = 48
        
        addi $t0, $zero, 87
        bge $a2, 97, return1
        addi $t0, $zero, 55
        bge $a2, 65 return1
        addi $t0, $zero, 48
        
        return1:
            sub $v1, $a2, $t0  		
            jr $ra
	
