.text

	main:

     jal getWord

    li $s5, 0 # s5 = main counter = number of guesses = attempt number
    li $s7, 0 # s7 = number of bulls
    li $v0, 30 #get start system time
    syscall #time is stored in a0
    move $s4, $a0 # s4 = system start time
    mainLoop:
    
    addi $s5, $s5, 1
    jal getInput
	
    jal continue #test if given up	
    
    jal Compare

    j output
    outReturn: #return label
    
    beq $s7, 4, success # if bulls = 4, print success and exit program
    beq $s5, 10, exit #after 10 attempts end program
    bne $s7, 4, mainLoop  # if bulls != 4 repeat the loop

j exit
######################################################################################################
	getInput:
	
#ask for string
li $v0, 4
la $a0, prompt
syscall

#take in string and save it to guess
li $v0, 8
la $a0, guess
li $a1, 5
la $s3, guess
syscall

#return to main
jr $ra
#######################################################################################################
	Compare: # s1 = word, s2 = (s1) = word address, 'guess' = guess address 

li $s6, 0 #s6 = number of cows
li $s7, 0 #s7 = number of bulls
li $t5, 0 #t5 = outer counter
li $t6, 0 #t6 = inner counter
move $t0, $s2 #t0 = outer address
la $t1, guess #t1 = inner address
   outer: #t8 = word offset	
    li $t6, 0 # reset inner counter
    la $t1, guess # reset inner address
    lb $t3, ($t0) # t3 = outer byte
      inner: #t9 = guess offset
      lb $t4,($t1) # t4 = inner byte
      beq $t3, $t4, compareAddress
      ret: # return label, returns from compareAdress
      
      addi $t1, $t1, 1 # increment inner address
      addi $t6, $t6, 1 #increment inner counter
      bne $t6, 4, inner
   
   addi $t0, $t0, 1 #increment outer address
   addi $t5, $t5, 1 #increment outer counter
   bne $t5, 4, outer
   jr $ra
###############################################################################
	compareAddress:
	
	sub $t7, $t0, $s2 # t7 = word offset
	la $t8, guess
	sub $t8, $t1, $t8 # t8 = guess offset
	li $v0, 4
	la $a0, debug
	beq $t7, $t8, incrementBull #if offset is equal branch to increment bull
	addi $s6, $s6, 1 # else increment cows
	j ret # return to compare
	
	incrementBull:
	addi $s7, $s7, 1 #increment bull
	j ret # return to compare

###########################################################################################
	getWord:
	
#implement code to choose a random word by adjusting the offest on $t1
li $v0, 42
li $a1, 100 # upper bound = 100
syscall # a0 = random int
sll $t0, $a0, 2 #multiply random int by 4 so it is a multiple of 4
la $s0, words #s0 = address of array of words
add $s0, $s0, $t0 #increment by random amount 
lw $s1, ($s0) #s1 = address of specific word 
li $v0, 4
move $a0, $s1
syscall
la $s2, ($s1) # s2 = address of first letter of word = address of word
# address of letter = s2 + offset
li $t5, 0 #t5 = counter
move $s7, $ra # s7 = return address to main
#jal iterateWord

move $ra, $s7 #restore return address to send to main
jr $ra

#################################################################
	output:
	
li $v0, 4
la $a0, attempt
syscall
li $v0, 1
move $a0, $s5
syscall
li $v0, 4
la $a0, yourGuess
syscall
li $v0, 4
la $a0, guess
syscall
li $v0, 4
la $a0, thereWere
syscall
li $v0, 1
move $a0, $s6
syscall
li $v0, 4
la $a0, cows
syscall
li $v0, 4
la $a0, thereWere
syscall
li $v0, 1
move $a0, $s7
syscall
li $v0, 4
la $a0, bulls
syscall
j outReturn

########################################################################################
	success:
li $v0, 4
la $a0, correct
syscall
j winSound
###########################################################################################
winSound:   
	li $t1, 72
	li $t2, 270
	li $t3, 127
	li $t4, 200
	jal play
	jal sleep
	jal play
	jal sleep
	jal play
	jal sleep
	li $t2, 700
	li $t4, 500
	jal play
	jal sleep
	li $t1, 68
	li $t4, 500
	jal play
	jal sleep
	li $t1, 70
	jal play
	jal sleep
	li $t1, 72
	li $t2, 400
	li $t4, 250
	jal play
	jal sleep
	li $t2, 150
	li $t3, 0
	li $t4, 110
	jal play
	jal sleep
	li $t2, 250
	li $t3, 127
	li $t1, 70
	li $t4, 200
	jal play
	jal sleep
	li $t1, 72
	li $t2, 1300
	jal play
	jal sleep
	
	j exit

play:
	move $a0, $t1
	move $a1, $t2
	li $a2, 1
	move $a3, $t3
	li $v0, 31
	syscall
	
	jr $ra
	
sleep:
	move $a0, $t4
	li $v0, 32
	syscall
	
	jr $ra
##################################################################################
	continue:
	
li $t5, 0 #t5 = loop counter
li $t6, 0 # t6 = match counter
la $t7, done # t7 = address of done
lb $t0, ($t7)
la $t8, guess # t8 = address of guess
   contLoop:
   
   addi $t5, $t5, 1
   lb $t0, ($t7) # t0 = single letter of done
   lb $t1, ($t8) # t1 = single letter of guess
   beq $t0, $t1, incrementMatch
   incReturn:
   
   addi $t7, $t7, 1 # add loop counter to address
   addi $t8, $t8, 1 # add loop counter to address
   bne $t5, 4, contLoop
   beq $t6, 4, forceQuit
   jr $ra
   
   incrementMatch:
   
   addi $t6, $t6, 1
   li $v0, 4
   la $a0, debug
   syscall
   j incReturn
   
############################################################################################
	forceQuit:
li $v0, 4
la $a0, newLine	
syscall
li $v0, 4
la $a0, quit
syscall
      
#############################################################################################
	exit:
	
li $v0, 30 #get ending system time
syscall

sub $s4, $a0, $s4 #s4 = finish time - start time
li $v0, 4
la $a0, time 
syscall

div $s4, $s4, 1000 #convert from milliseconds to seconds

li $v0, 1
move $a0, $s4
syscall
	
li $v0, 10
syscall
########################################################################################

.data
words: .word word0,word1,word2,word3,word4,word5,word6,word7,word8,word9,word10,word11,word12,word13,word14,word15,word16,word17,word18,word19,word20,word21,word22,word23,word24,word25,word26,word27,word28,word29,word30,word31,word32,word33,word34,word35,word36,word37,word38,word39,word40,word41,word42,word43,word44,word45,word46,word47,word48,word49,word50,word51,word52,word53,word54,word55,word56,word57,word58,word59,word60,word61,word62,word63,word64,word65,word66,word67,word68,word69,word70,word71,word72,word73,word74,word75,word76,word77,word78,word79,word80,word81,word82,word83,word84,word85,word86,word87,word88,word89,word90,word91,word92,word93,word94,word95,word96,word97,word98,word99
guess: .word 4
debug: .asciiz "DEBUG!!!"
prompt: "\nPlease enter a word:\n"
cows: .asciiz " cows"
bulls: .asciiz " bulls"
thereWere: .asciiz "\nthere were  "
yourGuess: .asciiz "\nYour guess was:\t"
attempt: .asciiz "\nAttempt #"
correct: .asciiz "\nYou are correct!"
time: .asciiz "\nThis game took this many seconds: "
quit: .asciiz"You have quit the game"
done: .asciiz "done"
newLine: .asciiz "\n"
word0: .asciiz "cows"
word1: .asciiz "word"
word2: .asciiz "mage"
word3: .asciiz "main"
word4: .asciiz "mile"
word5: .asciiz "mind"
word6: .asciiz "acne"
word7: .asciiz "ages"
word8: .asciiz "aloe"
word9: .asciiz "arts"
word10: .asciiz "bike"
word11: .asciiz "blue"
word12: .asciiz "bent"
word13: .asciiz "bone"
word14: .asciiz "cafe"
word15: .asciiz "cats"
word16: .asciiz "chef"
word17: .asciiz "coin"
word18: .asciiz "dabs"
word19: .asciiz "desk"
word20: .asciiz "dong"
word21: .asciiz "dump"
word22: .asciiz "easy"
word23: .asciiz "envy"
word24: .asciiz "epic"
word25: .asciiz "evil"
word26: .asciiz "face"
word27: .asciiz "fear"
word28: .asciiz "film"
word29: .asciiz "flux"
word30: .asciiz "gain"
word31: .asciiz "germ"
word32: .asciiz "gold"
word33: .asciiz "game"
word34: .asciiz "hags"
word35: .asciiz "halt"
word36: .asciiz "herb"
word37: .asciiz "host"
word38: .asciiz "idle"
word39: .asciiz "info"
word40: .asciiz "item"
word41: .asciiz "into"
word42: .asciiz "jade"
word43: .asciiz "jock"
word44: .asciiz "jump"
word45: .asciiz "jolt"
word46: .asciiz "kegs"
word47: .asciiz "kids"
word48: .asciiz "kite"
word49: .asciiz "knob"
word50: .asciiz "lack"
word51: .asciiz "lady"
word52: .asciiz "lewd"
word53: .asciiz "life"
word54: .asciiz "nail"
word55: .asciiz "nice"
word56: .asciiz "next"
word57: .asciiz "nhut"
word58: .asciiz "oaks"
word59: .asciiz "omen"
word60: .asciiz "open"
word61: .asciiz "oven"
word62: .asciiz "pace"
word63: .asciiz "peck"
word64: .asciiz "pink"
word65: .asciiz "pony"
word66: .asciiz "quad"
word67: .asciiz "quiz"
word68: .asciiz "quit"
word69: .asciiz "race"
word70: .asciiz "ream"
word71: .asciiz "ride"
word72: .asciiz "road"
word73: .asciiz "rust"
word74: .asciiz "sack"
word75: .asciiz "scan"
word76: .asciiz "sign"
word77: .asciiz "slow"
word78: .asciiz "taco"
word79: .asciiz "thin"
word80: .asciiz "torn"
word81: .asciiz "tuna"
word82: .asciiz "ugly"
word83: .asciiz "used"
word84: .asciiz "unit"
word85: .asciiz "void"
word86: .asciiz "vine"
word87: .asciiz "vote"
word88: .asciiz "verb"
word89: .asciiz "wage"
word90: .asciiz "wasp"
word91: .asciiz "wine"
word92: .asciiz "worm"
word93: .asciiz "yarn"
word94: .asciiz "vape"
word95: .asciiz "zero"
word96: .asciiz "zone"
word97: .asciiz "sing"
word98: .asciiz "bird"
word99: .asciiz "look"
