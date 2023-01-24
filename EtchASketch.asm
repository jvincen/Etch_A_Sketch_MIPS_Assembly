# Title:  Etch A Sketch
# Desc:   A program that emulates an Etch-A-Sketch
# Author: Joseph Vincent
# Date:   12/07/2021

.eqv BIT_MAP_ADDR	0x10040000	# Base address for bitmap display
.eqv GREY		0x00808080	# Color grey for border
.eqv WHITE  		0x00ffffff	# Color white for middle dot
.eqv KC			0xffff0004	# Used to read data
.eqv KR			0xffff0000	# To check if it is ok to write (Key Ready?)

.text
  .globl main
main:
  
  # Load the neccessary eqv
  li $s0, BIT_MAP_ADDR
  li $s1, KR
  
  # Allocate memory in the Heap to hold your 512 x 512 display
  li $a0, 16384
  li $v0, 9
  syscall

  # Draw a white dot in the middle
  addi $s0, $s0, 8064
  li $t0, WHITE
  sw $t0, 0($s0)

  # Going back to base address again
  li $s0, BIT_MAP_ADDR

  # Draw border
  li $a0, GREY			# Color
  addi $a1, $s0, 0  		# Moving base address to $a1
  li $a2, 64        		# Length of 64
  jal DRAW_HORIZONTAL_LINE

  li $a0, GREY
  addi $a1, $s0, 16128
  li $a2, 64
  jal DRAW_HORIZONTAL_LINE

  li $a0, GREY
  addi $a1, $s0, 0
  li $a2, 64
  jal DRAW_VERTICAL_LINE

  li $a0, GREY
  addi $a1, $s0, 508
  li $a2, 64
  jal DRAW_VERTICAL_LINE

  # Set up to handle interrupts.
  li $t0, 2
  sb $t0, 0($s1)		# Set bit 2 in KR
  
  # Changing the base address so that the current location is the white dot
  addi $s0, $s0, 8064
  sw $s0, bma
  
# Infinite loop with few random lines of code
Inf_Loop:
  addi $t0, $t0, 0
  b Inf_Loop

  # Exit
  li $v0, 10
  syscall

# Subroutine to draw an horizonal line
.text
  DRAW_HORIZONTAL_LINE:  
    # Prolog
    subi $sp, $sp, 12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # Logic
    move $s0, $a0		# Color  
    move $s1, $a1   		# Base
    move $s2, $a2  		# Length

    li $t0, 0       		# i = 0
DHL_FOR_LOOP1:
    slt $t1, $t0, $s2  		# As long as $t0 is < $s2
    beq $t1, $zero, DHL_END_FOR_LOOP1
      sw $s0, 0($s1)   		# Write to the screen
      
      addi $t0, $t0, 1		# i++
      addi $s1, $s1, 4 		# Increment our pointer
      b DHL_FOR_LOOP1

DHL_END_FOR_LOOP1:
    
    # Epilog
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    
    jr $ra
   
# Subroutine to draw a vertical line
.text
  DRAW_VERTICAL_LINE:  
    # Prolog
    subi $sp, $sp, 16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    # Logic
    move $s0, $a0		# Color  
    move $s1, $a1   		# Base
    move $s2, $a2  		# Length

    li $t0, 0       # i = 0
DHL_FOR_LOOP2:
    slt $t1, $t0, $s2  		# As long as $t0 is < $s2
    beq $t1, $zero, DHL_END_FOR_LOOP2 
      sw $s0, 0($s1)   		# Write to the screen
      
      addi $t0, $t0, 1		# i++
      addi $s1, $s1, 256  	# Increment our pointer
      b DHL_FOR_LOOP2

DHL_END_FOR_LOOP2:
    
    # Epilog
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    
    jr $ra
 
.kdata
  color:	.word	0x000000ff	# Start with blue
  bma:	.word	0x10040000	# Base address for bitmap display

.ktext 0x80000180
  # Prolog
  subi $sp, $sp, 16
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  
  # Logic
  la $s0, KC
  # Call handleKeyInput
  lw $a0, 0($s0)
  jal handleKeyInput
  
  # Epilog
  lw $s2, 12($sp)
  lw $s1, 8($sp)
  lw $s0, 4($sp)
  lw $ra, 0($sp)
  addi $sp, $sp, 16
  eret

handleKeyInput:
  # Prolog
  sub $sp, $sp, 16
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  
  move $t0, $a0				# Pressed key
  
  # Check which key was entered and call the corresponding handleKey# (works with Capital and small letters)
  beq $t0, 0x00000077, handleKeyw
  beq $t0, 0x00000061, handleKeya
  beq $t0, 0x00000073, handleKeys
  beq $t0, 0x00000064, handleKeyd
  beq $t0, 0x00000069, handleKeyI
  beq $t0, 0x0000006f, handleKeyO
  beq $t0, 0x0000006b, handleKeyK
  beq $t0, 0x0000006c, handleKeyL
  beq $t0, 0x00000057, handleKeyW
  beq $t0, 0x00000041, handleKeyA
  beq $t0, 0x00000053, handleKeyS
  beq $t0, 0x00000044, handleKeyD
  beq $t0, 0x00000072, handleKeyR
  beq $t0, 0x00000067, handleKeyG
  beq $t0, 0x00000062, handleKeyB
  beq $t0, 0x00000071, handleKeyQ
handleKeyInputEpilog:
  # Epilog
  lw $s2, 12($sp)
  lw $s1, 8($sp)
  lw $s0, 4($sp)
  lw $ra, 0($sp)
  addi $sp, $sp, 16
  jr $ra

# Moves up and draws a pixel
handleKeyw:
  lw $t0, bma
  lw $t1, color
  subi $t0, $t0, 256			# Moves up
  lw $t2, 0($t0)				# Load the color of the current location
  beq $t2, 0x00808080, border_endw	# Check if the current position is the border, if yes- skip drawing the pixel
  or $t1, $t1, $t2			# Bit/Wise or of the existing color and the new color
  sw $t1, 0($t0)				# Draw pixel
  sw $t0, bma				# Save bitmap address
border_endw:
  b handleKeyInputEpilog
# Moves left and draws a pixel
handleKeya:
  lw $t0, bma
  lw $t1, color
  subi $t0, $t0, 4			# Moves left
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_enda
  or $t1, $t1, $t2
  sw $t1, 0($t0)
  sw $t0, bma
border_enda:
  b handleKeyInputEpilog
# Moves down and draws a pixel
handleKeys:
  lw $t0, bma
  lw $t1, color
  addi $t0, $t0, 256			# Moves down
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_ends
  or $t1, $t1, $t2
  sw $t1, 0($t0)
  sw $t0, bma
border_ends:
  b handleKeyInputEpilog
# Moves right and draws a pixel
handleKeyd:
  lw $t0, bma
  lw $t1, color
  addi $t0, $t0, 4			# Moves right
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_endd
  or $t1, $t1, $t2
  sw $t1, 0($t0)
  sw $t0, bma
border_endd:
  b handleKeyInputEpilog
# Moves up/left and draws a pixel
handleKeyI:
  lw $t0, bma
  lw $t1, color
  subi $t0, $t0, 260			# Moves up/left
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_endI
  or $t1, $t1, $t2
  sw $t1, 0($t0)
  sw $t0, bma
border_endI:
  b handleKeyInputEpilog
# Moves up/right and draws a pixel
handleKeyO:
  lw $t0, bma
  lw $t1, color
  subi $t0, $t0, 252			# Moves up/right
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_endO
  or $t1, $t1, $t2
  sw $t1, 0($t0)
  sw $t0, bma
border_endO:
  b handleKeyInputEpilog
# Moves down/left and draws a pixel
handleKeyK:
  lw $t0, bma
  lw $t1, color
  addi $t0, $t0, 252			# Moves down/left
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_endK
  or $t1, $t1, $t2
  sw $t1, 0($t0)
  sw $t0, bma
border_endK:
  b handleKeyInputEpilog
# Moves down/right and draws a pixel
handleKeyL:
  lw $t0, bma
  lw $t1, color
  addi $t0, $t0, 260			# Moves down/right
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_endL
  or $t1, $t1, $t2
  sw $t1, 0($t0)
  sw $t0, bma
border_endL:
  b handleKeyInputEpilog
# Moves up and delete pixel
handleKeyW:
  lw $t0, bma
  lw $t1, color
  subi $t0, $t0, 256			# Moves up
  lw $t2, 0($t0)				# Load the color of the current location
  beq $t2, 0x00808080, border_endW	# Check if the current position is the border, if yes- skip deleting the pixel
  li $t1, 0				# Load 0
  sw $t1, 0($t0)				# Delete pixel
  sw $t0, bma				# Save bitmap address
border_endW:
  b handleKeyInputEpilog
# Moves left and delete pixel
handleKeyA:
  lw $t0, bma
  lw $t1, color
  subi $t0, $t0, 4			# Moves left
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_endA
  li $t1, 0
  sw $t1, 0($t0)
  sw $t0, bma
border_endA:
  b handleKeyInputEpilog
# Moves down and delete pixel
handleKeyS:
  lw $t0, bma
  lw $t1, color
  addi $t0, $t0, 256			# Moves down
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_endS
  li $t1, 0
  sw $t1, 0($t0)
  sw $t0, bma
border_endS:
  b handleKeyInputEpilog
# Moves right and delete pixel
handleKeyD:
  lw $t0, bma
  lw $t1, color
  addi $t0, $t0, 4			# Moves right
  lw $t2, 0($t0)
  beq $t2, 0x00808080, border_endD
  li $t1, 0
  sw $t1, 0($t0)
  sw $t0, bma
border_endD:
  b handleKeyInputEpilog
# Changes color gradient by adding 30 to the current R value
handleKeyR:
  lw $t1, color
  addi $t1, $t1, 0x00300000
  sw $t1, color
  b handleKeyInputEpilog
# Changes color gradient by adding 30 to the current G value
handleKeyG:
  lw $t1, color
  addi $t1, $t1, 0x00003000
  sw $t1, color
  b handleKeyInputEpilog
# Changes color gradient by adding 30 to the current B value
handleKeyB:
  lw $t1, color
  addi $t1, $t1, 0x00000030
  sw $t1, color
  b handleKeyInputEpilog
# Terminate the program
handleKeyQ:
  li $v0, 10
  syscall
