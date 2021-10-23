.data
	available_items: .asciiz "--- Available Items ---\n"
	items: 	.align 3
			.asciiz "Potato"
			.align 3
			.asciiz "Tomato"
			.align 3
			.asciiz "Olive"
			.align 3
			.asciiz "Chili"
			.align 3
			.asciiz "Lettuce"
			.align 3
			.asciiz "Beef"
			.align 3
			.asciiz "Chicken"
			.align 3
			.asciiz "Cheese"
			.align 3
			.asciiz "Flour"
			.align 3
			.asciiz "Salt "
			# .align 3
	kg: .asciiz " KG"
	quantities: .word 8, 9, 15, 13, 13, 13, 9, 10, 6, 13
	thresholds: .word 4, 6, 8, 5, 6, 7, 8, 3, 6, 7
	num_items: .word 10
	prompt_item: .asciiz "Select item (1-10): "
	invalid_item: .asciiz "Invalid item! Try again (1-10): "
	prompt_quantity: .asciiz "Enter quantity: "
	invalid_quantity: .asciiz "Invalid quantity! Threshold of item is "
	password: .word 12345
	prompt_password: .asciiz "Enter password: "
	invalid_password: .asciiz "Invalid password! Try again: "
	fetched_item: .asciiz "Item fetched successfully\n"
	prompt_continue: .asciiz "Continue (1), Exit (0): "
	

.text
	main:
		# load address of quantities to $s0
		la $s0, quantities
		# load address of thresholds to $s1
		la $s1, thresholds
		# number of items
		lw $s2, num_items
		# initializing index for printing item number and quantities
		li $s3, 0
		# initializing index for printing item name
		li $s5, 0
		# prompt user with "Available Items" message
		li $v0, 4
		la $a0, available_items
		syscall
		# branch to print_items
		b print_items

	# print list of items with their available quantities in KG
	print_items:
		# print number of item (1, 2, 3, ...) from index in $s3
		li $t0, 0
		add $t0, $t0, $s3
		addi $t0, $t0, 1
		li $a0, 0
		add $a0, $a0, $t0
		li $v0, 1
		syscall
		# print a space
		jal space
		# print item name
    	la $a0, items
		add $a0, $a0, $s5
		li $v0, 4
    	syscall
    	addi $s5, $s5, 8
    	# print a space
    	jal space
    	# print quantity of item
    	mul $s4, $s3, 4
   	 	add $s4, $s4, $s0
    	lw $a0, 0($s4)
		li $v0, 1
		syscall
		# print label "KG"
		li $v0, 4
		la $a0, kg
		syscall
		# print a newline
		jal newline
		# increment the index $s3
		addi $s3, $s3, 1
		# if iterated through all indecies, branch to select_item
		beq $s3, $s2, select_item
		# else, branch again to print_item
		b print_items

	# print a newline
	newline:
		li $v0, 11
		li $a0, 0xA
		syscall
		jr $ra
	
	# print a space
	space:
		li $v0, 11
		li $a0, 0x20
		syscall
		jr $ra
	
	# prompt user to select item from the given 10 items
	select_item:
		jal newline
		# user prompt to enter item number (1-10)
		li $v0, 4
		la $a0, prompt_item
		syscall
		# user input item number (1-10)
		li $v0, 5
		syscall
		# move result from $v0 to $t0
		move $t0, $v0
		# if user input >= to 11, branch to verify_item
		slti $t1, $t0, 11
		beq $t1, $zero, verify_item
		# if user input <= to 0, branch to verify_item
		slt $t2, $zero, $t0
		beq $t2, $zero, verify_item
		# if user input is valid (<11 and >0), branch to enter_quantity
		b enter_quantity
	
	# ask user to re-enter item number
	verify_item:
		# prompt user that the number entered is invalid
		li $v0, 4
		la $a0, invalid_item
		syscall
		# user input item number again
		li $v0, 5
		syscall
		# move result from $v0 to $t0
		move $t0, $v0
		# if user input >= to 11, branch to verify_item
		sltiu  $t1, $t0, 11
		beq $t1, $zero, verify_item
		# if user input <= to 0, branch to verify_item
		slt $t2, $zero, $t0
		beq $t2, $zero, verify_item
		# if user input is valid (<11 and >0), branch to enter_quantity
		b enter_quantity
	
	# prompt user to enter desired quantity to fetch
	enter_quantity:
		# user prompt to enter desired quantity
		li $v0, 4
		la $a0, prompt_quantity
		syscall
		# user input desired quantity
		li $v0, 5
		syscall
		# move result from $v0 to $t0
		move $t1, $v0
		# branch to verify quantity
		b verify_quantity
		
	# verify that after fetching the quantity, the new quantity will be >= threshold
	verify_quantity:
		# compute index of item from the entered item number $t0	
		li $t9, 0
		add $t9, $t9, $t0
		subi $t9, $t9, 1		
		# compute the index of quantities
		mul $s4, $t9, 4
   	 	add $s4, $s4, $s0
		# fetch quantity of selected item
		lw $t5, 0($s4)
		# compute new quantity by subtracting available quantity and desired quantity
		sub $t5, $t5, $t1
		# compute the indes of thresholds
		mul $s4, $t9, 4
		add $s4, $s4, $s1
		# fetch threshold of selected item
		lw $t6, 0($s4)
		# if new quantity < threshold, branch to invalid_qt
		slt $t7, $t5, $t6
		bne $t7, $zero, invalid_qt
		# compute index of selected item
		mul $s4, $t9, 4
   	 	add $s4, $s4, $s0
   	 	# store/update the quantity of selected item 
		sw $t5, 0($s4)
		# branch to enter_password
		b enter_password
	
	# prompt user that the entered quantity will violate the threshold constraints
	invalid_qt:
		# prompt user that the quantity entered violates the threshold
		li $v0, 4
		la $a0, invalid_quantity
		syscall		
		# print the threshold of selected item
		li $v0, 1
		li $a0, 0
		add $a0, $a0, $t6
		syscall
		# print a newline
		jal newline
		# branch to continue
		b continue
	
	# authenticating user by prompt for a password
	enter_password:
		# prompt user to enter the password
		li $v0, 4
		la $a0, prompt_password
		syscall
		# user input the password
		li $v0, 5
		syscall
		# move result from $v0 to $t2
		move $t2, $v0
		# fetch password from data memory for verification
		lw $t8, password
		# if enter password != actual password, branch to verify_password
		bne $t2, $t8, verify_password
		# branch to feedback
		b feedback
	
	# ask user to re-enter password if it's incorrect
	verify_password:
		# prompt user that entered password is invalid
		li $v0, 4
		la $a0, invalid_password
		syscall
		# user input password again
		li $v0, 5
		syscall
		# move result from $v0 to $t2
		move $t2, $v0
		# fetch password from data memory for verification
		lw $t8, password
		# if enter password != actual password, branch to verify_password
		bne $t2, $t8, verify_password
		# branch to feedback
		b feedback
	
	# provide feedback to user that the item is fetched
	feedback:
		# print feedback message
		li $v0, 4
		la $a0, fetched_item
		syscall
		# branch to continue
		b continue
		
	# ask user if he/she wants to fetch other items
	continue:
		# prompt user to continue
		li $v0, 4
		la $a0, prompt_continue
		syscall
		# user input choice (0-exit)
		li $v0, 5
		syscall
		# move result from $v0 to %t3
		move $t3, $v0
		# if choice != 0, branch to main (repeating the program)
		bne $t3, $zero, main
		# if choice == 0, exit program
		li $v0, 10
		syscall
