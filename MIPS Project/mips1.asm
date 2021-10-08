.data
	N:.word 10
	keys:.word 0
	hash:.space 40	
	Menu:.asciiz " Menu\n"
	InsertKey:.asciiz "1.Insert Key\n"
	FindKey:.asciiz "2.Find Key\n"
	DisplayHash:.asciiz "3.Display Hash Table\n"
	Exit:.asciiz "4.Exit\n"
	Choice:.asciiz "\nChoice?"
	NewKey:.asciiz"Give new key(greater than zero): "
	WrongKey:.asciiz"Key must be greater than zero\n"
	SearchKey:.asciiz "Give key to search for: "
	KeyNotFound:.asciiz"Key not in hash table.\n"
	KeyValue:.asciiz"Key value= "
	TablePos:.asciiz "Table position= "
	KeyFound:.asciiz"Key is already in hash table.\n"
	FullHash:.asciiz"Hash table is full\n"
	PosKey:.asciiz"\npos  key\n"
	Empty:.asciiz" "
	Empty2:.asciiz"  "
	changeline:.asciiz"\n"

.text
.globl main
main:
run:
	lw $t0,N  #$t0=N
	lw $t1,keys #$t1=keys
	la $t2,hash #loading the address of the hash table in $t2
	li $t3,0 #i=0;

#for (int i=0; i<N; i++) hash[i]=0;	
for:
	beq $t3,$t0,exit
	sw $zero,($t2)
	
	
	addi $t2,$t2,4
	addi $t3,$t3,1
	j for
exit:

	li $t2,0  #telos=0;
do:	
	#println(" Menu");
	li $v0,4
	la $a0,Menu
	syscall
	
	li $v0,4
	la $a0,InsertKey
	syscall
	
	
	li $v0,4
	la $a0,FindKey
	syscall
	
	li $v0,4
	la $a0,DisplayHash
	syscall
	
	li $v0,4
	la $a0,Exit
	syscall
	
	li $v0,4
	la $a0,Choice
	syscall
	
	li $v0,5
	syscall

	
	beq $v0,1,if1
	beq $v0,2,if2
	beq $v0,3,if3
	beq $v0,4,if4
if1:
	
	li $v0,4
	la $a0,NewKey
	syscall
	
	li $v0,5
	syscall
	ble $v0,$zero,NegativeKey
	la $a1,hash
	move $a2,$v0 #$a2=key
	jal insertkey
	j while
NegativeKey:
	
	li $v0,4
	la $a0,WrongKey
	syscall
	j while

if2:
	
	li $v0,4
	la $a0,SearchKey
	syscall
	li $v0,5
	syscall
	move $a2,$v0 #$a2=key
	jal findkey
	beq $v1,-1,IF15
	j ELSE15
IF15:
	li $v0,4
	la $a0,KeyNotFound
	syscall
	j while
ELSE15:
	li $v0,4
	la $a0,KeyValue
	syscall	
	li $v0,1
	lw $a0,hash($v1)
	syscall										
	div $v1,$v1,4
	li $v0,4
	la $a0,changeline
	syscall	
	li $v0,4
	la $a0,TablePos
	syscall										
	li $v0,1
	move $a0,$v1
	syscall		
	li $v0,4
	la $a0,changeline
	syscall										
										
										
	
	j while
if3:
	jal displaytable
	j while

if4:
	li $t2,1
while:
	beq $t2,1,END_PROGRAM
	j do
	
END_PROGRAM:	
	#end of program
	li $v0,10
	syscall
	
	
				
						
								
												
insertkey:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal findkey
	bne $v1,-1,IF3
	j ELSE3
IF3:
	li $v0,4
	la $a0,KeyFound
	syscall
	j Endinsertkey
ELSE3:
	blt $t1,$t0,IF4
	j ELSE4
IF4:
	jal hashfunction
	sw $a2,hash($v1)
	addi $t1,$t1,1
	j Endinsertkey
ELSE4:
	
	li $v0,4
	la $a0,FullHash
	syscall	
Endinsertkey:
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	


	
		
hashfunction:
	rem $t5,$a2,$t0	#position=k%n;	
	mul $t6,$t5,4
	lw $t7,hash($t6)							
while20:
	beq $t7,0,exit20
	
	addi $t5,$t5,1
	rem $t5,$t5,$t0 #position %=N;								
	mul $t6,$t5,4									
	lw $t7,hash($t6)										
	j while20
exit20:
	mul $v1,$t5,4
	jr $ra											
													
														
																

findkey:	
	
	li $t3,0 #i=0;
	li $t4,0 #found=0;
	rem $t5,$a2,$t0 #position=k%n;
while6:
	bge $t3,$t0,exit6
	bne $t4,$zero,exit6
	addi $t3,$t3,1
	mul $t6,$t5,4
	lw $t7,hash($t6)
	beq $t7,$a2,IF10
	j ELSE10
IF10:
	addi $t4,$t4,1
	j exit6
ELSE10:
	addi $t5,$t5,1
	rem $t5,$t5,$t0
	j while6
												
																
exit6:
	beq $t4,1,IF11
	j ELSE11
IF11:
	mul  $v1,$t5,4
	j Endfindkey
ELSE11:
	li $v1,-1
Endfindkey:																								
	jr $ra																															
																																								
																																																
																																																								
																																																																
																																																																																																																																																							
																																																																																																																																																																																								
																																																																																																								
																																																																																																																																		
displaytable:
	li $t3,0  #i=0;
	la $t4,hash #loading the address of the hash table in $t4
	
	#
	li $v0,4
	la $a0,PosKey
	syscall
while5:
	bge $t3,$t0,exit5
	lw $t5,($t4)
	
	li $v0,4
	la $a0,Empty2
	syscall										
	
	li $v0,1
	move $a0,$t3
	syscall
	
	li $v0,4
	la $a0,Empty2
	syscall										
	
	li $v0,1
	move $a0,$t5
	syscall
	
	li $v0,4
	la $a0,changeline
	syscall										
	
	addi $t4,$t4,4
	addi $t3,$t3,1
	j while5
exit5:
	jr $ra
																											
																
																		
																						
		