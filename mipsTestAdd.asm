.text
.globl	main
main:
#Made By Dana Ghnimat 1200031 Section 1

	#open a file for reading
  	li $v0, 13 # system call for open file
 	la $a0, filename # file name
  	li $a1, 0
 	syscall

  	move $s0, $v0 # save the file descriptor

	# read from file
  	li $v0, 14
  	move $a0, $s0              # file descriptor
  	la $a1, calender         # address of input to which to read
  	li $a2, 1024                   # hardcoded input length
  	syscall
  
	# Close the file 
	li $v0, 16
	move $a0, $s0
	syscall
	#print the calender
	li $v0, 4
	la $a0, calender 
	syscall 
	
	# notify the user that the calender is loaded 
	li $v0, 4
	la $a0,file_load_msg
	syscall
	
	b menu
#----------------------------------------------------
menu:
	# Prompt user for file existence
    	li $v0, 4                # system call code for printing a string
    	la $a0, menu_msg  # address of the message
    	syscall                  # print the message
    	# Read a single character from the user
    	li $v0, 12               # system call code for reading a single character
   	syscall                  # read the character from the console
 	move $t0, $v0  # store the response in $t0            # load the character into $t0

    	# Check if the file exists
    	beq $t0, 'v', viewCalender   # branch to view calender
    	beq $t0, 's', viewStats  # branch to statics
    	beq $t0, 'a', addAppoint   # branch to add appoitnment
    	beq $t0, 'd', deleteAppoint   # branch to delete appointment
    	beq $t0, 'q', exit_program
	j error_msg
	
	
viewCalender:
	li $v0,4
	la $a0 , viewMsg
	syscall # print the message
	
	# Read a single character from the user
    	li $v0, 12               # system call code for reading a single character
   	syscall                  # read the character from the console
 	move $t0, $v0  # store the response in $t0            # load the character into $t0

    	# Check if the file exists
    	beq $t0, '1', viewPerDay   # branch to view calender
    	beq $t0, '2', viewSetDays  # branch to statics
    	beq $t0, '3', viewSlot   # branch to add appoitnment
    	beq $t0, 'r', menu
	j error_msg_c
	
	li $v0 ,4
	la $a0 , return_msg
	syscall # print the message
	
	j menu
	
#------------------------------------------------------------------	
viewPerDay:
	# Prompt user for file existence
    	li $v0, 4                # system call code for printing a string
    	la $a0, viewDay_msg  # address of the message
    	syscall                  # print the message
    	
    	# Read the numberr from the user
    	li $v0, 5              # system call code for reading an integer
   	syscall                  # read the character from the console
 	move $t1, $v0  # store the response in $t1
 	
	jal search
	j menu 
#--------------------------------------------------------------------------
search:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	la $s2,calender
    	#buffer 1 to hold the day num readed
	la $s3,buffer1
	#buffer 2 to hold the information to be printed
	la $s4,buffer2
loopCalender:
	# Load a byte from the memory address stored in $s2 and store it in $t0
	lbu $t0,($s2)
	#if it reached the end of the file, then it 
	#did not find the day number
	beqz $t0, notFound
	# 10 is the ASCCII code for \n
	beq $t0,10,new_Line 
	addi $s2,$s2,1
	#store the byte to buffer2
	sb $t0,0($s4)
	addi $s4,$s4,1
	#check if we reached the colon ':'
	beq $t0,58,colon
	# Store the byte in $t0 to the memory address stored in $s3
	sb $t0,0($s3)
	addi $s3,$s3,1
	
	j loopCalender
	
colon:
	# Store null character at the end of buffer1
	sb $zero, ($s3) 
	
	 la $a0,buffer1
	 jal to_Integer
	 move $t2,$v1
	 
	  #comparing between the readed integer and
	  #the integer taked from user
	  beq $t1,$t2,day_found
	  
	  #if they are not equel then move to the next line
	  la $a0,buffer1
	  jal clear_string
	  la $a0,buffer2
	  jal clear_string
	
	  la $s3,buffer1
	  la $s4,buffer2 
	  j loopCalender
		
new_Line:
	#increment the address of the calender
	addi $s2,$s2,1
	
	#clear strings and return to the first address of
	#buffer1 and buffer2
	la $a0,buffer1
	jal clear_string
	la $a0,buffer2
	jal clear_string
	
	la $s3,buffer1
	la $s4,buffer2 
	j loopCalender

day_found:	
	#continue storing to the end of the line
	lb $t0,0($s2)
	beqz $t0,printResult
	beq $t0,10,printResult
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	j day_found
	
printResult:
	#add null terminator to the end of the buffer2
	sb $zero,0($s3)
	
	#printing the result
	li $v0,4
	la $a0,buffer2
	syscall
	
	#print a new line char
	li $v0,11
	li $a0,10
	syscall
	
	#clearing buffers
	la $a0,buffer1
	jal clear_string
	la $a0,buffer2
	jal clear_string
	
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr   $ra
	
notFound:
	#print a message that the day not found
	li $v0,4
	la $a0,notFoundDay
	syscall
	
	#clearing buffers
	la $a0,buffer1
	jal clear_string
	la $a0,buffer2
	jal clear_string
	
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr   $ra
#---------------------------------------------------------------------------
viewSetDays:
	# Prompt user for file existence
    	li $v0, 4                # system call code for printing a string
    	la $a0, view_set_msg  # address of the message
    	syscall                  # print the message
    	
    	# Read the numberr from the user
    	li $v0, 8
  	la $a0, days_entered         # address of input to which to read
  	li $a1, 100                   # hardcoded input length
  	syscall
  	
 	la $a0, days_entered
    	la $a1, bufferDays
 	jal search_set
 	j menu 
#----------------------------------------------------------------------------
search_set:
    move $t5, $a0         # t0 = address of input string
    move $t6, $a1         # t1 = address of output string

    loop:
    
        lb $t7, 0($t5)     # Load a byte from input string
	addi $t5, $t5, 1
        beq $t7, 10, end    # If it's the null terminator, end the loop
        # Check if the current character is a comma
        beq $t7, 44, skip   # If it's a comma, skip to the next character
        # Copy the character to the output string
        sb $t7, 0($t6)
        addi $t6, $t6, 1
        # Move to the next character in both input and output strings
        j loop

    skip:
        li $t8, 0
        sb $t8, 0($t6)
                
       	#convert print the days and convert each into an integer
	li $v0, 4
        la $a0, bufferDays
	syscall	
	#move what has been written in v0 into t4
	move $t4, $v0
	jal to_Integer
	#after conversion print a line
	li $v0, 4
        la $a0, newLine
        syscall
        #and search for the days 
	move $t1,$v1
	jal search
	#print a line after each search 	
        li $v0, 4
        la $a0, newLine
        syscall
        
    	la $t6, bufferDays
        #Reset the output string for the next part

        j loop

    end:
	j menu
#===========================================================================	
viewSlot:
	#Print the day massage:
	li $v0, 4
	la $a0, view_per_slot
	syscall 	
    	# Read the numberr from the user
    	li $v0, 5              # system call code for reading an integer
   	syscall                  # read the character from the console
 	move $t1, $v0  # store the response in $t1
 	
	jal search_day # Search the day in search 
	#after that the search stored it in $v1 value then move it to t1 	
	#li $v0,4
	#la $a0,buffer2
	#syscall
	li $v0,4
	la $a0, newLine
	syscall
	
	li $v0,4
	la $a0,Search_the_slot
	syscall
	
	li $v0 , 5
	syscall
	move $t1, $v0  # store the response in $t1
	jal check_ifinvalid #check if the number is invalid
	
	li $v0,4
	la $a0,Search_the_slot2
	syscall
	
	li $v0 , 5
	syscall
	move $s1, $v0  # store the response in $s1
	jal check_ifinvalid #check if number is invalid 
	
	jal search_slot1
        
# Display the result


	
	j menu
	
#---------------------------------------------------------------------------

search_day:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	la $s2,calender
    	#buffer 1 to hold the day num readed
	la $s3,buffer1
	#buffer 2 to hold the information to be printed
	la $s4,buffer2
loopCalender_2:
	# Load a byte from the memory address stored in $s2 and store it in $t0
	lbu $t0,($s2)
	#if it reached the end of the file, then it 
	#did not find the day number
	beqz $t0, notFound
	# 10 is the ASCCII code for \n
	beq $t0,10,new_Line_2 
	addi $s2,$s2,1
	#store the byte to buffer2
	sb $t0,0($s4)
	addi $s4,$s4,1
	#check if we reached the colon ':'
	beq $t0,58,colon_2
	# Store the byte in $t0 to the memory address stored in $s3
	sb $t0,0($s3)
	addi $s3,$s3,1
	
	j loopCalender_2
	
colon_2:
	# Store null character at the end of buffer1
	sb $zero, ($s3) 
	
	 la $a0,buffer1
	 jal to_Integer
	 move $t2,$v1
	 
	  #comparing between the readed integer and
	  #the integer taked from user
	  beq $t1,$t2,day_found_2
	  
	  #if they are not equel then move to the next line
	  la $a0,buffer1
	  jal clear_string
	  la $a0,buffer2
	  jal clear_string
	
	  la $s3,buffer1
	  la $s4,buffer2 
	  j loopCalender_2
		
new_Line_2:
	#increment the address of the calender
	addi $s2,$s2,1
	
	#clear strings and return to the first address of
	#buffer1 and buffer2
	la $a0,buffer1
	jal clear_string
	la $a0,buffer2
	jal clear_string
	
	la $s3,buffer1
	la $s4,buffer2 
	j loopCalender_2

day_found_2:	
	#continue storing to the end of the line
	lb $t0,0($s2)
	beqz $t0,printResult_2
	beq $t0,10,printResult_2
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	j day_found_2
	
printResult_2:
	#add null terminator to the end of the buffer2
	sb $zero,0($s3)
	
	#printing the result
	li $v0,4
	la $a0,buffer2
	syscall
		
	#clearing buffers
	la $a0,buffer1
	jal clear_string

	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr   $ra
		
#----------------------------------------------------------------------------
search_slot1:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	la $s2,buffer2
    	#buffer 4 to hold the day num readed
	la $s3,buffer4
	#buffer 5 to hold the information to be printed
	la $s4,buffer5
		
loop_slot:
	# Load a byte from the memory address stored in $s2 and store it in $t0
	lbu $t0,($s2)
	#if it reached the end of the line then
	#did not find the slot number
	beq $t0,0, SlotnotFound
	# 10 is the ASCCII code for ":"
	beq $t0,58,clear_day
	#check if we reached the comma ','
	beq $t0,44,new_slot 
	addi $s2,$s2,1
	#store the byte to buffer5
	sb $t0,0($s4)
	addi $s4,$s4,1
	#check if we reached the minus '-'
	beq $t0,45,minus1
	# Store the byte in $t0 to the memory address stored in $s3

	sb $t0,0($s3)
	addi $s3,$s3,1
	
	
	j loop_slot
	
minus1:
	# Store null character at the end of buffer4
	 sb $zero, ($s3) 
	 la $a0,buffer4
	 
	 
	# li $v0,4
	 la $a0,1($a0)
	 #syscall
	 
	 jal to_Integer
	 move $t2,$v1

	 #li $v0,11
	 #li $a0,10
	 #syscall 
	 #j slot_found
	 #comparing between the readed integer and
	 #the integer taked from user
	 bge $t1,$t2,check_hour2
	  
	 #if they are not equel then move to the next line
	 la $a0,buffer4
	 jal clear_string
	 la $a0,buffer5
	 jal clear_string
	
	 la $s3,buffer4
	 la $s4,buffer5 
	 j loop_slot

check_hour2:
	# Store null character at the end of buffer4
	 sb $zero, ($s3) 
	 lb $t0,($s2) 
	 	 
	 #li $v0,4
	 la $a0,($s2)
	# syscall
	 

	 jal to_Integer
	 move $t2,$v1
	 
	 li $v0,4
	 la $a0,new_line
	 syscall


	 #comparing between the readed integer and

	 ble $s1,$t2,slot_found
	 
	  
	 #if they are not equel then move to the next line
	 la $a0,buffer4
	 jal clear_string
	 la $a0,buffer5
	 jal clear_string
	
	 la $s3,buffer4
	 la $s4,buffer5 
	 j loop_slot
		
new_slot:
	#increment the address of the calender
	addi $s2,$s2,1
	
	#clear strings and return to the first address of
	#buffer1 and buffer2
	la $a0,buffer4
	jal clear_string
	la $a0,buffer5
	jal clear_string
	
	la $s3,buffer4
	la $s4,buffer5 
	j loop_slot
clear_day:
	#increment the address of the calender
	addi $s2,$s2,1
	
	#clear strings and return to the first address of
	#buffer1 and buffer2
	la $a0,buffer4
	jal clear_string
	la $a0,buffer5
	jal clear_string
	
	la $s3,buffer4
	la $s4,buffer5 
	j loop_slot
slot_found:	
	#continue storing to the end of the line
	lb $t0,0($s2)
	beqz $t0,printSlot
	beq $t0,44,printSlot
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	j slot_found
	
printSlot:
	#add null terminator to the end of the buffer2
	sb $zero,0($s3)
	
	#printing the result
	li $v0,4
	la $a0,buffer5
	syscall
	
	#print a new line char
	li $v0,11
	li $a0,10
	syscall
	
	#clearing buffers
	la $a0,buffer4
	jal clear_string
	la $a0,buffer5
	jal clear_string
	
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr   $ra
	
SlotnotFound:
	#print a message that the day not found
	li $v0,4
	la $a0,notFoundSLot
	syscall
	
	#clearing buffers
	la $a0,buffer4
	jal clear_string
	la $a0,buffer5
	jal clear_string
	
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr   $ra
#============================================================================
viewStats:

	
	jal getAllTheStats
	
	j menu
#-----------------------------------------------------------------------------------------------
getAllTheStats:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	la $s2,calender
    	#buffer 1 to hold the day num readed
	la $s3,buffer1
	#buffer 1 For number of days 	  
	lw $s4,numOfDaysBuffer

loopCalender_Stat:
	# Load a byte from the memory address stored in $s2 and store it in $t0
	lbu $t0,($s2)
	#if it reached the end of the file, then it 

	beqz $t0,printResult_ForStats
	beq $t0,10,new_Line_skiping
	# 10 is the ASCCII code for \n
	addi $s2,$s2,1
	beq $t0,58,day_found_5
	j loopCalender_Stat
	
new_Line_skiping:
	addi $s2,$s2,1 #skip the line character 
	add $s4,$s4,1 #increment the num of days 
	sw $s4,numOfDaysBuffer #store the number of days 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1
	#Clean buffers to add new Data 
	j loopCalender_Stat
	

		
day_found_5:		#after that we already found the date , so we will take the first number 
	lb $t0,0($s2)
	beqz $t0,printResult_ForStats
	beq $t0,32, skip_spaceStats
	beq $t0,45, get_thetimeSTL #if it equal minus branch into get_thetime to get the numbers 
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s3) #store it into s3 later on for comparasion 
	addi $s3,$s3,1
	j day_found_5
#the current logic we will use is to get first and second time , then check the type. 
 
get_thetimeSTL:
	#initiate t1 to use it for sum operations 
	 li $t1,0
	 li $s1,0 	
check_firstnumStat:	
	sb $zero, ($s3) #load the number into the buffer and check it 
	la $a0,buffer1
	jal to_Integer
	move $t2,$v1
	
	addu $t1,$t1,$t2
		
	#li $v0,4
	#la $a0,buffer1
	#syscall	
	
	b getSecondNumberCheckStats
	
check_secnumStat:
	
	sb $zero, ($s3) 
	la $a0,buffer1
	jal to_Integer
	move $t2,$v1
	
	subu $s1,$t2,$t1
	
	
	#li $v0,4
	#la $a0,buffer1
	#syscall
	
	#li $v0,4
	#la $a0,new_line
	#syscall	
	
	b getTypeToStore	
	
		
skip_spaceStats:
	addi $s2,$s2,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1	
	j day_found_5
	
getSecondNumberCheckStats:
	addi $s2,$s2,1 #increament to next byte
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1
	loopR:
		lb $t0,($s2)
		addi $s2,$s2,1 #increament to next byte
		sb $t0,0($s3) #store it into s3 later on for comparasion 
		addi $s3,$s3,1
		beq $t0,32,check_secnumStat
		b loopR


getTypeToStore:
	lb $t0,0($s2)
	
#	li $v0,4
#	la $a0,0($s2)
#	syscall
	
	beq $t0,'L',addToLectures
	beq $t0,'O',addToHours
	beq $t0,'M',addTomeetings
	
	b check_slot_State
		
addToLectures:
	lw $t0,bufferSumL	
	add $t0,$t0,$s1	
	sw $t0,bufferSumL
	j check_slot_State	
addToHours:
	lw $t0,bufferSumOH	
	add $t0,$t0,$s1	
	sw $t0,bufferSumOH
	j check_slot_State
addTomeetings:
	lw $t0,bufferSumM	
	add $t0,$t0,$s1	
	sw $t0,bufferSumM
	j check_slot_State


									
check_slot_State:
	lb $t0,0($s2)
	beqz $t0,printResult_ForStats
	beq $t0,10 , new_Line_skiping #go to a new day 
	beq $t0,32, check_next_slotStats
	beq $t0,45, get_thetimeSTL #if it equal minus branch into get_thetime to get the numbers 
	beq $t0,44, check_next_slotStats
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s3) #store it into s3 later on for comparasion 
	addi $s3,$s3,1
	j check_slot_State

check_next_slotStats:
	addi $s2,$s2,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1	
	j check_slot_State	
	
printResult_ForStats:
	#-=-=-=---==--=-=-=-=-=-=-=-=-=-==-=--=-=--=-==-=-
	li $v0 ,4
	la $a0 , viewStatics1
	syscall # print the message
	
	li $v0 ,4
	la $a0 , viewStatics2
	syscall # print the message
		
	li $v0 ,4
	la $a0 , viewStatics3
	syscall # print the message

	# Read a single character from the user
    	li $v0, 12               # system call code for reading a single character
   	syscall                  # read the character from the console
 	move $t0, $v0  # store the response in $t0            # load the character into $t0

	
    	beq $t0, '1', numofLectures   # branch 
    	beq $t0, '2', numOfHours  # branch 
    	beq $t0, '3', numOfmeeting   # branch to
    	beq $t0, '4', avLectrures    # branch to 
    	beq $t0, '5', ratioOfL   # branch to 
    	beq $t0, 'r', menu
	j error_msg_s
	
	li $v0 ,4
	la $a0 , return_msg
	syscall # print the message
	j menu
	
	numofLectures:
		li $v0,4
		la $a0,numOfHoursForL
		syscall	
		lw $t0, bufferSumL #Load the value of 
		move $a0, $t0 #move the value from $t0 to $a0
		li $v0, 1 #set syscall number for printing an integer
		syscall #print the integer
		b donePrinting
		
	numOfHours:
		li $v0,4
		la $a0,numOfHoursForOH
		syscall		
		lw $t0, bufferSumOH #Load the value of office hours
		move $a0, $t0 #move the value from $t0 to $a0
		li $v0, 1 #set syscall number for printing an integer
		syscall #print the integer
		b donePrinting
		
	numOfmeeting:	
		li $v0,4
		la $a0,numOfHoursForM
		syscall		
		lw $t0, bufferSumM #Load the value of meetings
		move $a0, $t0 #move the value from $t0 to $a0
		li $v0, 1 #set syscall number for printing an integer
		syscall #print the integer	
		b donePrinting
		
	avLectrures:
		li $v0,4
		la $a0,numOfHoursForAverage
		syscall	
		lw $t0, bufferSumL # get the number of lectures
		mtc1.d $t0, $f0 #move to convert
		cvt.d.w $f0, $f0 #convert $t0 to double and store in $f0
		
		lw $t1, numOfDaysBuffer
		mtc1.d $t1, $f2 #move to convert
		cvt.d.w $f2, $f2 #convert $t1 to double and store in $f1
		
		div.d $f2, $f0, $f2 #divide $f0 by $f1 and store the result in $f2
		
		li $v0, 3
		mov.d $f12, $f2 #print the result as double
		syscall
		b donePrinting
	ratioOfL: # i wasnt too sure what rerio refer to so ill add it as " ratio = (total lecture hours) / (total office hours)" 
		li $v0,4
		la $a0,numOfHoursForRatio
		syscall	
		lw $t0, bufferSumL # get the number of lectures
		mtc1.d $t0, $f0 #move to convert
		cvt.d.w $f0, $f0 #convert $t0 to double and store in $f0
		
		lw $t1, bufferSumOH #Load the value of 	office hours	
		mtc1.d $t1, $f2 #move to convert
		cvt.d.w $f2, $f2 #convert $t1 to double and store in $f1
		
		div.d $f2, $f0, $f2 #divide $f0 by $f1 and store the result in $f2
		
		li $v0, 3
		mov.d $f12, $f2 #print the result as double
		syscall	
		b donePrinting
		
		
	donePrinting:	
	#print a new line char
	li $v0,4
	la $a0,new_line
	syscall	
	#clearing buffers reset them back to 0 , so no additional number be saved 
	la $a0,buffer1
	jal clear_string	
	li $t0,0	
	sw $t0,bufferSumOH
	li $t0,0	
	sw $t0,bufferSumM
	li $t0,0	
	sw $t0,bufferSumL
	li $t0,1
	sw $t0,numOfDaysBuffer
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	j menu					



#----------------------------------------------------------------------------------------------
addAppoint:
	#Ask the user t enter a day so search to add the appointment to :
	li $v0,4
	la $a0, addDay_msg
	syscall
	
	
	li $v0, 5              # system call code for reading an integer
   	syscall                  # read the character from the console
 	move $t1, $v0  # store the response in $t1
	jal search_toAdd
	
	li $v0 ,4
	la $a0 , return_msg
	syscall # print the message
	
	j menu
#=======================================================================
search_toAdd:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	la $s2,calender
    	#buffer 1 to hold the day num readed
	la $s3,buffer1
	#buffer 2 to hold the information to be stored into and clear the buffer to make sure its empty 	  
	la $s4,buffer2
	
loopCalender_3:
	# Load a byte from the memory address stored in $s2 and store it in $t0
	lbu $t0,($s2)
	#if it reached the end of the file, then it 
	#did not find the day number
	beqz $t0, notFound_3
	beq $t0,10,new_Line_3
	# 10 is the ASCCII code for \n
	addi $s2,$s2,1
	sb $t0,0($s4)	
	addi $s4,$s4,1
	#check if we reached the colon ':'
	beq $t0,58,colon_3
	# Store the byte in $t0 to the memory address stored in $s3
	sb $t0,0($s3)
	addi $s3,$s3,1

	
	j loopCalender_3
	
new_Line_3:
	addi $s2,$s2,1
	sb $t0,0($s4)	
	addi $s4,$s4,1
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1

	j loopCalender_3
	
colon_3:
	# Store character 
	# Store null character at the end of buffer1
	 sb $zero, ($s3) 
	 la $a0,buffer1
	 jal to_Integer
	 move $t2,$v1
	 
	  #comparing between the readed integer and
	  #the integer taked from user
	 beq $t1,$t2,day_found_3
	  
	  #if they are not equel then move to the next line
	 la $a0,buffer1
	 jal clear_string
	# la $a0,buffer2
	# jal clear_string
	# la $s4,buffer2
	 la $s3,buffer1	  
	 j loopCalender_3
		



day_found_3:		#after that we already found the date , so we will 
	lb $t0,0($s2)
	beqz $t0,printResult_3
	beq $t0,32, skip_space
	beq $t0,45, get_thetime #if it equal minus branch into get_thetime to get the numbers 
	beq $t0,44, check_next_slot
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	sb $t0,0($s3) #store it into s3 later on for comparasion 
	addi $s3,$s3,1
	j day_found_3
#the time have to follow the logic of : 
#if time1 < first time , and time2 < first time then add it 
#if time1 > first time , then check if time1 is also > second time or else could be between the two times of appointment 
#then check if time2 > second time , then go next slot and check  
#if it reached last slot , add , else continue without adding.
 
enterRightTime:
	li $v0,4
	la $a0, reEnterNumbers #let the user enter the first number 
	syscall
get_thetime:
	li $v0,4
	la $a0, Search_the_slot #let the user enter the first number 
	syscall	


	li $v0, 8
	la $a0,bufferTime1 
	li $a1, 10 
	syscall
	jal to_Integer
	move $t1,$v1
	jal check_ifinvalid #check if the number is invalid
	
	li $v0,4
	la $a0, Search_the_slot2 #let the user enter the second number 
	syscall	
	
	li $v0, 8
	la $a0,bufferTime2
	li $a1, 10 
	syscall
	jal to_Integer
	move $s1,$v1
	jal check_ifinvalid #check if the number is invalid
	 
	bge $t1,$s1, enterRightTime
	
	
check_firstnum:	
	sb $zero, ($s3) #load the number into the buffer and check it 
	la $a0,buffer1
	jal to_Integer
	move $t2,$v1
	
	blt $t1,$t2,check_firstnum2 #if the first number is less than the first hour  check the second number 
	bgt $t1,$t2,check_secnum 
	b notFound_3
	
check_firstnum2:
	lb $t0,0($s2)
	ble $s1,$t2,searchSpace_toAdd #if the second time is also less than the furst hour add it 
	j notFound_3
	
check_firstnum3:
	sb $zero, ($s3) #load the number into the buffer and check it 
	la $a0,buffer1
	jal to_Integer
	move $t2,$v1
#	li $v0,4
#	la $t0,($a0)
#	syscall

	
	blt $t1,$t2,check_firstnum4 #if the first number is less than the first hour  check the second number 
	bgt $t1,$t2,check_secnum 
	b notFound_3
	
check_firstnum4:
	lb $t0,0($s2)
	ble $s1,$t2,searchSpace_toAdd #if the second time is also less than the furst hour add it 
	j notFound_3
			

check_secnum:

	lb $t0,0($s2)
	
#	li $v0,4
#	la $a0,new_line
#	syscall	
	sb $zero, ($s3) 
	la $a0,buffer1
	jal to_Integer
	move $t2,$v1
	

	blt $s1,$t2,searchSpace_toAdd
	bgt $s1,$t2,incrementationOG
	beq $s1,$t2 notFound_3
	b notFound_3
check_secnum2:

	lb $t0,0($s2)
	
#	li $v0,4
#	la $a0,new_line
#	syscall	
	sb $zero, ($s3) 
	la $a0,buffer1
	jal to_Integer
	move $t2,$v1
	

	blt $s1,$t2,searchSpace_toAdd
	bgt $s1,$t2,incrementation
	beq $s1,$t2 notFound_3
	b notFound_3
		
continue_theslot:
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	
	j continue_thecalender
		
skip_space:
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1	
	j day_found_3
	
check_next_slot:
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1	
	j day_found_3
	
incrementationOG:
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	sb $t0,0($s3) #store it into s3 later on for comparasion 
	addi $s3,$s3,1
	b check_secnum2	
incrementation:
	addi $s2,$s2,1
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	sb $t0,0($s3) #store it into s3 later on for comparasion 
	addi $s3,$s3,1	
	
check_slot_2:
	lb $t0,0($s2)
	beqz $t0,continue_thecalender
	beq $t0,10 , add_TheSlot_toCalender2
	beq $t0,32, skip_space2
	beq $t0,45, check_firstnum3 #if it equal minus branch into get_thetime to get the numbers 
	beq $t0,44, check_next_slot2
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	sb $t0,0($s3) #store it into s3 later on for comparasion 
	addi $s3,$s3,1
	j check_slot_2

check_next_slot2:
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1	
	j check_slot_2	
	
skip_space2:
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1		
	j check_slot_2		

searchSpace_toAdd: #go backwatd until you reach the begining of the slot, 

	lb $t0,0($s2)
	beq $t0,32, add_TheSlot_toCalender1
	subi $s2,$s2,1
	subi $s4,$s4,1
	j searchSpace_toAdd
	
add_TheSlot_toCalender1: #add the new slot 	
	li $t0,32
	sb $t0,($s4) #store space
	addi $s4,$s4,1 #increament to next byte
	#then store the first number 
	#li $v0 , 4
	la $a0, bufferTime1
	#syscall
	fullTime1:
		lb $t0,0($a0)	#load it into t0
		beq $t0,10, fullTime1done
		addi $a0,$a0,1
		sb $t0,($s4) 	#store it into s4
		addi $s4,$s4,1 #increament to next byte
		b fullTime1	
	fullTime1done:
	
#	li $v0, 4
#	la $a0, new_line
#	syscall 
	
	li $t0,'-'
	sb $t0,($s4) #store the "-"
	addi $s4,$s4,1 #increament to next byte
	
	#li $v0 , 4
	la $a0, bufferTime2
	#syscall
	fullTime2:
		lb $t0,0($a0)	#load it into t0
		beq $t0,10, fullTime2done
		addi $a0,$a0,1
		sb $t0,($s4) 	#store it into s4
		addi $s4,$s4,1 #increament to next byte
		b fullTime2	
	fullTime2done:
	#then add another space 
	li $t0,32
	sb $t0,($s4) #store space
	addi $s4,$s4,1 #increament to next byte
	#Now ask the user to enter the type
	li $v0,4
	la $a0, enter_type 
	syscall
	
	li $v0,8
	la $a0,bufferType
	la $a1,10
	syscall
	
	typeloop:
		lb $t0,0($a0)	#load it into t0
		beq $t0,10, doneHere
		addi $a0,$a0,1
		sb $t0,($s4) 	#store it into s4
		addi $s4,$s4,1
		b typeloop
	doneHere:
	
	li $t0,44
	sb $t0,($s4) #store space
	addi $s4,$s4,1 #increament to next byte
	
	
	j continue_thecalender
	
add_TheSlot_toCalender2: #add the new slot 
	li $t0,44
	sb $t0,($s4) #store space
	addi $s4,$s4,1 #increament to next byte	
	li $t0,32
	sb $t0,($s4) #store space
	addi $s4,$s4,1 #increament to next byte
	#then store the first number 
	#li $v0 , 4
	la $a0, bufferTime1
	#syscall
	fullTime3:
		lb $t0,0($a0)	#load it into t0
		beq $t0,10, fullTime1done2
		addi $a0,$a0,1
		sb $t0,($s4) 	#store it into s4
		addi $s4,$s4,1 #increament to next byte
		b fullTime3
	fullTime1done2:
	
#	li $v0, 4
#	la $a0, new_line
#	syscall 
	
	li $t0,'-'
	sb $t0,($s4) #store the "-"
	addi $s4,$s4,1 #increament to next byte
	
	#li $v0 , 4
	la $a0, bufferTime2
	#syscall
	fullTime4:
		lb $t0,0($a0)	#load it into t0
		beq $t0,10, fullTime2done2
		addi $a0,$a0,1
		sb $t0,($s4) 	#store it into s4
		addi $s4,$s4,1 #increament to next byte
		b fullTime4	
	fullTime2done2:
	#then add another space 
	li $t0,32
	sb $t0,($s4) #store space
	addi $s4,$s4,1 #increament to next byte
	#Now ask the user to enter the type
	li $v0,4
	la $a0, enter_type 
	syscall
	
	li $v0,8
	la $a0,bufferType
	la $a1,10
	syscall
	
	typeloop2:
		lb $t0,0($a0)	#load it into t0
		beq $t0,10, doneHere2
		addi $a0,$a0,1
		sb $t0,($s4) 	#store it into s4
		addi $s4,$s4,1
		b typeloop2
	doneHere2:
	
	
	
	j continue_thecalender	
	

				
continue_thecalender:	#after that we already found the date , so we will 
	lb $t0,0($s2)
	beqz $t0,printResult_3
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	j continue_thecalender	
		
printResult_3:
	#add null terminator to the end of the buffer2
	sb $zero,0($s3)
	
	#printing the result
	li $v0,4
	la $a0,buffer2
	syscall
	
	li   $v0, 13       # system call for open file
    	la $a0, calender2
    	li $a1, 1
    	li   $a2, 0        # mode is ignored
    	syscall  # File descriptor gets returned in $v0
    	move $s6, $v0      # save the file descriptor
    	li   $v0, 15       # system call for write to file
    	move $a0, $s6      # file descriptor 
	la   $a1, buffer2   # address of buffer from which to write
	li   $a2, 500       # hardcoded buffer length
	syscall            # write to file
	#file_close:
    	li $v0, 16  # $a0 already has the file descriptor
    	move $a0, $s6      # file descriptor to close
    	syscall	
	#print a new line char
	li $v0,11
	li $a0,10
	syscall
	
	#clearing buffers
	la $a0,buffer1
	jal clear_string
	la $a0,buffer2
	jal clear_string
	
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	j menu
	
notFound_3:
	#print a message that the day not found
	lb $t0,0($s2)
	li $v0,4
	la $a0,added_failed
	syscall
	j continue_thecalender


#-----------------------------------------------------------------------
deleteAppoint:	
	#Ask the user t enter a day so search to add the appointment to :
	li $v0,4
	la $a0, deleteDay_msg
	syscall
	
	
	li $v0, 5              # system call code for reading an integer
   	syscall                  # read the character from the console
 	move $t1, $v0  # store the response in $t1
	jal search_toDelete
	
	li $v0 ,4
	la $a0 , return_msg
	syscall # print the message
	
	j menu
#=======================================================================
search_toDelete:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	la $s2,calender
    	#buffer 1 to hold the day num readed
	la $s3,buffer1
	#buffer 2 to hold the information to be stored into and clear the buffer to make sure its empty 	  
	la $s4,buffer2
	
loopCalender_4:
	# Load a byte from the memory address stored in $s2 and store it in $t0
	lbu $t0,($s2)
	#if it reached the end of the file, then it 
	#did not find the day number
	beqz $t0, notFound_4
	beq $t0,10,new_Line_4
	# 10 is the ASCCII code for \n
	addi $s2,$s2,1
	sb $t0,0($s4)	
	addi $s4,$s4,1
	#check if we reached the colon ':'
	beq $t0,58,colon_4
	# Store the byte in $t0 to the memory address stored in $s3
	sb $t0,0($s3)
	addi $s3,$s3,1

	
	j loopCalender_4
	
new_Line_4:
	addi $s2,$s2,1
	sb $t0,0($s4)	
	addi $s4,$s4,1
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1

	j loopCalender_4
	
colon_4:
	# Store character 
	# Store null character at the end of buffer1
	 sb $zero, ($s3) 
	 la $a0,buffer1
	 jal to_Integer
	 move $t2,$v1
	 
	  #comparing between the readed integer and
	  #the integer taked from user
	 beq $t1,$t2,day_found_4
	  
	  #if they are not equel then move to the next line
	 la $a0,buffer1
	 jal clear_string

	 la $s3,buffer1	  
	 j loopCalender_4
		


day_found_4:		#after that we already found the date , so we will 
	lb $t0,0($s2)
	beqz $t0,printResult_4
	beq $t0,32, skip_spaceDelete
	beq $t0,45, get_thetimeD #if it equal minus branch into get_thetime to get the numbers 
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	sb $t0,0($s3) #store it into s3 later on for comparasion 
	addi $s3,$s3,1
	j day_found_4

 
enterRightTimeD:
	li $v0,4
	la $a0, reEnterNumbers #let the user enter the first number 
	syscall
get_thetimeD:
	li $v0,4
	la $a0, Search_the_slot #let the user enter the first number 
	syscall	
	
	li $v0, 8
	la $a0,bufferTime1 
	li $a1, 10 
	syscall
	jal to_Integer
	move $t1,$v1
	jal check_ifinvalid #check if the number is invalid
	
	li $v0,4
	la $a0, Search_the_slot2 #let the user enter the second number 
	syscall	
	
	li $v0, 8
	la $a0,bufferTime2
	li $a1, 10 
	syscall
	jal to_Integer
	move $s1,$v1
	jal check_ifinvalid #check if the number is invalid
	 
	bge $t1,$s1, enterRightTimeD
	
	
check_firstnumD:	
	sb $zero, ($s3) #load the number into the buffer and check it 
	la $a0,buffer1
	jal to_Integer
	move $t2,$v1
	

#	li $v0,4
#	la $a0,buffer1
#	syscall	
	

	beq $t1,$t2,getSecondNumberCheck
	bgt $t1,$t2, skip_space2Delete
	b notFound_4
		
	
check_secnumD2:
	
	li $v0,4
	la $a0,new_line
	syscall	
	sb $zero, ($s3) 
	la $a0,buffer1
	jal to_Integer
	move $t2,$v1
	
#	li $v0,4
#	la $a0,buffer1
#	syscall
	
	beq $s1,$t2,searchSpace_toDelete
	bgt $s1,$t2,skip_space2Delete
	b notFound_4 	
	
		
skip_spaceDelete:
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1	
	j day_found_4
	
getSecondNumberCheck:
	addi $s2,$s2,1 #increament to next byte
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1
	loopE:
		lb $t0,($s2)
		addi $s2,$s2,1 #increament to next byte
		sb $t0,0($s3) #store it into s3 later on for comparasion 
		addi $s3,$s3,1
		beq $t0,32,check_secnumD2
		b loopE


		
check_slot_3:
	lb $t0,0($s2)
	beqz $t0,continue_thecalenderDelete
	beq $t0,10 , continue_thecalenderDelete
	beq $t0,32, skip_space2Delete
	beq $t0,45, check_firstnumD #if it equal minus branch into get_thetime to get the numbers 
	beq $t0,44, check_next_slot3
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	sb $t0,0($s3) #store it into s3 later on for comparasion 
	addi $s3,$s3,1
	j check_slot_3

check_next_slot3:
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1	
	j check_slot_3	
	
skip_space2Delete:
	addi $s2,$s2,1
	sb $t0,0($s4)
	addi $s4,$s4,1
	#clear the previous data of the buffer and load it to store new data 
	la $a0,buffer1
	jal clear_string
	la $s3,buffer1		
	j check_slot_3		

searchSpace_toDelete: #go backwatd until you reach the begining of the slot, 
	
	lb $t0,0($s4)
	beq $t0,32, searchSpace_toDelete2
	subi $s4,$s4,1
	j searchSpace_toDelete
	
searchSpace_toDelete2:
	lb $t0,0($s2)
	addi $s2,$s2,1
	beq $t0,44, continue_thecalenderDelete
	j searchSpace_toDelete2	
				
continue_thecalenderDelete:	#after that we already found the date , so we will 
	lb $t0,0($s2)
	beqz $t0,printResult_4
	addi $s2,$s2,1 #increament to next byte
	sb $t0,0($s4) #store the current byte into S4 
	addi $s4,$s4,1 #incremeant
	j continue_thecalenderDelete	
		
printResult_4:
	#add null terminator to the end of the buffer2
	sb $zero,0($s3)
	
	#printing the result
	li $v0,4
	la $a0,buffer2
	syscall
	
	#file_open:
	li   $v0, 13       # system call for open file
    	la $a0, calender2
    	li $a1, 1
    	li   $a2, 0        # mode is ignored
    	syscall  # File descriptor gets returned in $v0
    	move $s6, $v0      # save the file descriptor
    	li   $v0, 15       # system call for write to file
    	move $a0, $s6      # file descriptor 
	la   $a1, buffer2   # address of buffer from which to write
	li   $a2, 500       # hardcoded buffer length
	syscall            # write to file
	#file_close:
    	li $v0, 16  # $a0 already has the file descriptor
    	move $a0, $s6      # file descriptor to close
    	syscall
	
	#print a new line char
	li $v0,11
	li $a0,10
	syscall
	
	#clearing buffers
	la $a0,buffer1
	jal clear_string
	la $a0,buffer2
	jal clear_string
	
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	j menu
	
notFound_4:
	#print a message that the day not found
	lb $t0,0($s2)
	li $v0,4
	la $a0,deleted_failed
	syscall
	j continue_thecalenderDelete
#---------------------------------------------------------------------------------------
error_msg:

    	li $v0, 4                # system call code for printing a string
    	la $a0, err_msg  # address of the message
    	syscall                  # print the message
    	# Read a single character from the user
    	li $v0, 12               # system call code for reading a single character
   	syscall                  # read the character from the console
 	move $t0, $v0  # store the response in $t0            # load the character into $t0

    	# Check if the file exists
    	beq $t0, 'y', menu  # branch to file_exists if user entered 'y'
    	beq $t0, 'Y', menu   # branch to file_exists if user entered 'Y'
    	j main	  
    	
error_msg_c:

    	li $v0, 4                # system call code for printing a string
    	la $a0, err_msg  # address of the message
    	syscall                  # print the message
    	# Read a single character from the user
    	li $v0, 12               # system call code for reading a single character
   	syscall                  # read the character from the console
 	move $t0, $v0  # store the response in $t0            # load the character into $t0

    	# Check if the file exists
    	beq $t0, 'y', viewCalender  # branch to file_exists if user entered 'y'
    	beq $t0, 'Y', viewCalender   # branch to file_exists if user entered 'Y'
    	j menu 
    	
error_msg_s:

    	li $v0, 4                # system call code for printing a string
    	la $a0, err_msg  # address of the message
    	syscall                  # print the message
    	# Read a single character from the user
    	li $v0, 12               # system call code for reading a single character
   	syscall                  # read the character from the console
 	move $t0, $v0  # store the response in $t0            # load the character into $t0

    	# Check if the file exists
    	beq $t0, 'y', viewStats  # branch to file_exists if user entered 'y'
    	beq $t0, 'Y', viewStats   # branch to file_exists if user entered 'Y'
    	j menu  
#---------------------------------------------------------------------------------------   	   			

clear_string:
	# Allocate space on the stack for the temporary address
	addi $sp, $sp, -4   
	# Save the return address on the stack  
	sw $ra, ($sp)         
	
	# Load the first character of the string
	lb $s5, 0($a0)   
	# If the character is null, we are done     
	beqz $s5, doneclear        

loopclear:
	# Store null byte at the current address
	sb $zero, 0($a0)    
	# Increment the address by 1  
	addiu $a0, $a0, 1   
	# Load the next character  
	lb $s5, 0($a0)       
	# If the character is not null, continue looping
	bnez $s5, loopclear        

doneclear:
	# Restore the return address from the stack
	lw $ra, ($sp) 
	# Deallocate space on the stack        
	addi $sp, $sp, 4      
	# Return from the function
	jr $ra            
	   
#----------------------------------------------------------------------------------------------------        			  		  		  		  	
to_Integer:
	#this is a function to convert an ascii number
	#to integer, its address stored in $a0
	#return the number in $v1
	
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
	lb $t8,0($a0)
	lb $t9,1($a0)
	blt $t9,48,oneDigit
	bgt $t9,57,oneDigit
twoDigit:
	addi $t8,$t8,-48
	mul $t8,$t8,10
	addi $t9,$t9,-48
	add $v1,$t8,$t9
  	
  	# Restore the return address from the stack
	lw $ra, ($sp) 
	# Deallocate space on the stack        
	addi $sp, $sp, 4      
	# Return from the function
	jr $ra 
oneDigit:
	addi $t8,$t8,-48
	move $v1,$t8
  	
	# Restore the return address from the stack
	lw $ra, ($sp) 
	# Deallocate space on the stack        
	addi $sp, $sp, 4      
	# Return from the function
	jr $ra 
#-----------------------------------------------------------------------------------
check_ifinvalid:
	li  $t2,8
	blt $t1,$t2,invalid_msg
	li  $t2,17
	bgt $t1,$t2,invalid_msg
	
	li  $t2,8
	blt $s1,$t2,invalid_msg_2
	li  $t2,17
	bgt $s1,$t2,invalid_msg_2
	

	jr $ra	
	
invalid_msg:	
	li $v0,4
	la $a0, time_invalid #Print the invalid msg
	syscall
			
	li $v0,5
	syscall
	move $t1,$v0
	#Then check again if the new number is invalid as well 
	blt $t1,8,check_ifinvalid
	bgt $t1,17,check_ifinvalid
	#if not then jump again to previous state 

	jr $ra	
	
invalid_msg_2:	
	li $v0,4
	la $a0, time_invalid #Print the invalid msg
	syscall
			
	li $v0,5
	syscall
	move $s1,$v0
	#Then check again if the new number is invalid as well 
	blt $s1,8,check_ifinvalid
	bgt $s1,17,check_ifinvalid
	#if not then jump again to previous state
 
	jr $ra	




#-----------------------------------------------------------------------------------
exit_program:
    # Print a message to inform the user that the program is exiting
    li $v0, 4             # system call code for printing a string
    la $a0, exit_msg      # address of the message
    syscall                # print the message

    li $v0, 16       # system call code for close file
    move $a0, $v0     # use file descriptor from open() as argument
    syscall          # close input file
    li $v0, 16       # system call code for close file
    move $a0, $v1     # use file descriptor from open() as argument
    syscall          # close output file
    
    # Exit program
    li $v0, 10       # system call code for exit program             	
    syscall

.data
filename: .asciiz "C:\\Users\\CS Net Games\\Desktop\\Arch\\calender.txt"
calender: .space 1024
calender2: .asciiz "C:\\Users\\CS Net Games\\Desktop\\Arch\\calender2.txt"
file_load_msg: .asciiz "\nThe file loaded successfully! \n"
exit_msg: .asciiz "\n Exiting the program... \n"
menu_msg: .asciiz "\n*** The start menu: *** \n-v View the calender \n-s View the statistics \n-a Add a new appointment \n-d Delete an appoitnment\n-q Close the program\n"
read_msg: .asciiz "\n\n The file loaded succesfully\n"
viewMsg: .asciiz "\n1- View per day \n2- View per selected day \n3- View from given slot from given day\n-r return to menu\n"
viewStatics1:  .asciiz "\n1- number of lectures (in hours)\n2- number of OH (in hours)\n3- number of Meetings (in hour)\n"
viewStatics2:  .asciiz "4- the average lectures per day\n"
viewStatics3:  .asciiz "5- the ratio between total number of hours reserved for lectures and the total number of hours reserved OH\n-r return to menu\n" 

return_msg: .asciiz "\n returning to the main menu \n" 
err_msg: .asciiz "\nthe option does not exist do you want to go back to the menu or exit ? y/n \n"
new_line: .asciiz "\n"
viewDay_msg: .asciiz"\n Enter the day: "
notFoundDay: .asciiz "This day does not exist in the calender yet\n\n"
view_set_msg: .asciiz "\nPlease enter the set of days you want to view make sure it ends with *,* \n"
view_per_slot: .asciiz "\nPlease write a given day \n"
view_slot: .asciiz "\n enter the day\n" 
Search_the_slot: .asciiz "\nEnter the first hour\n"
Search_the_slot2: .asciiz "\nEnter the Second hour\n"
notFoundSLot: .asciiz "This slot does not exist in this day yet\n\n"
time_invalid: .asciiz "\nThis is an invalid time, enter another one From 8 To 17 accurding to working time \n" 
addDay_msg: .asciiz"\n Enter the day you want to add the appointment to: "
deleteDay_msg: .asciiz"\n Enter the day you want to delete the appointment to: "
reEnterNumbers: .asciiz "\nPlease ReEnter new time; as first hour is less than second hour\n"
added_failed: .asciiz "\n adding failed return to the menu\n"
deleted_failed:  .asciiz "\n deleting failed return to the menu\n"
enter_type: .asciiz "\n Enter type \n"

numOfHoursForL: .asciiz "\nnumber of lectures (in hours)\n"
numOfHoursForOH: .asciiz "\nnumber of Office Hours (in hours)\n"
numOfHoursForM: .asciiz "\nnumber of Meetings (in hours)\n"
numOfHoursForAverage: .asciiz "\naverage lectures per day\n"	
numOfHoursForRatio: .asciiz "\naverage lectures per day\n"


buffer1: .space 500
buffer2: .space 500
buffer3: .space 500
days_entered: .space 100

bufferSumL: .word 0
bufferSumOH: .word 0
bufferSumM: .word 0
numOfDaysBuffer: .word 1

bufferDays: .space 100
temp_buff: .space 100

buffer4: .space 500
buffer5: .space 500
buffer6: .space 500

bufferTime1: .space 20
bufferTime2: .space 20
bufferType: .space 100

newLine: .asciiz "\n"
