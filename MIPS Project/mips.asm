#Epameinwndas Iwannou, AM:3140059
#Nestwr Behs-Sofoulhs, AM:3140129

	.text
	.globl main

main:	
	#$t0=N
	lw $t0,N  
	
	#$t1=keys
	lw $t1,keys 
	
	#storing $t1 in the stack because we are going to use it inside a function
	addi $sp,$sp,-4
	sw $t1,0($sp)
	
	#loading the address of the hash table in $t2 so we can use it in the for loop
	la $t2,hash 
	
	#i=0;
	li $t3,0 

#for (int i=0; i<N; i++) hash[i]=0;	
for:
	beq $t3,$t0,exit
	sw $zero,($t2)
	
	
	addi $t2,$t2,4
	addi $t3,$t3,1
	j for
exit:
	#telos=0;
	li $t2,0  
	
	
DO:	
	#println(" Menu");
	li $v0,4
	la $a0,Menu
	syscall
	
	#println("1.Insert Key");
	li $v0,4
	la $a0,InsertKey
	syscall
	
	#println("2.Find Key");
	li $v0,4
	la $a0,FindKey
	syscall
	
	#println("3.Display Hash Table");
	li $v0,4
	la $a0,DisplayHash
	syscall
	
	#println("4.Exit");
	li $v0,4
	la $a0,Exit
	syscall
	
	#print("\nChoice?");
	li $v0,4
	la $a0,Choice
	syscall
	
	#user makes a choice
	li $v0,5
	syscall


	beq $v0,1,if1
	beq $v0,2,if2
	beq $v0,3,if3
	beq $v0,4,if4


#if choice==1
if1:
	#print("Give new key(greater than zero):");
	li $v0,4
	la $a0,NewKey
	syscall
	
	#user gives a key
	li $v0,5
	syscall
	
	bgt $v0,$zero,IF1
	j ELSE1
	
	#if key>0
	IF1:	
		
		#$a1 will be used for indexes of hash table
		li $a1,0
		
		#$a2=key
		move $a2,$v0 
		
		#insertkey(int[]hash,int k)
		jal insertkey
		
		j WHILE
	
	#else
	ELSE1:
	
		#println("Key must be greater than zero");
		li $v0,4
		la $a0,WrongKey
		syscall
	
		j WHILE

#if choice==2
if2:	
	
	#print("Give key to search for:");
	li $v0,4
	la $a0,SearchKey
	syscall
	
	#user gives a key to search for
	li $v0,5
	syscall
	
	#$a1 will be used for indexes of hash table
	li $a1,0
	
	#$a2=key
	move $a2,$v0 
	
	#findkey(hash,key)
	jal findkey
	
	beq $v1,-1,IF2
	j ELSE2
	
	#if pos==-1
	IF2:
		#println("Key not in hash table.");
		li $v0,4
		la $a0,KeyNotFound
		syscall
		
		j WHILE
	#else
	ELSE2:	
		#println("Key value=");
		li $v0,4
		la $a0,KeyValue
		syscall	
		
		#print hash[pos];
		li $v0,1
		lw $a0,hash($v1)
		syscall										
		
		#dividing with 4 to print the position
		div $v1,$v1,4
		
		#Change line
		li $v0,4
		la $a0,changeline
		syscall	
		
		#println("Table position=");
		li $v0,4
		la $a0,TablePos
		syscall										
		
		#print pos;
		li $v0,1
		move $a0,$v1
		syscall		
		
		#Change line
		li $v0,4
		la $a0,changeline
		syscall										
		
		j WHILE
	
#if choice==3
if3:	
	#$a1 has the address of the hash table
	la $a1,hash
	
	#displaytable(hash);
	jal displaytable
	
	j WHILE

#if choice==4
if4:	
	#telos=1;
	li $t2,1

WHILE:	
	#if telos==1 goto END_PROGRAM
	beq $t2,1,END_PROGRAM
	
	j DO
		
END_PROGRAM:	
	#restoring $t1 from the stack
	lw $t1, 0($sp)
	addi $sp,$sp,4
	
	#end of program	
	li $v0,10
	syscall
	
	
				
												

#void insertkey(int[] hash,int k)																								
insertkey:
	#storing the register $ra in the stack
	addi $sp,$sp,-4
	sw $ra,4($sp)
	
	#calling findkey
	jal findkey
	
	bne $v1,-1,IF
	j ELSE

#if position!=-1
IF:
	#println("Key is already in hash table.");
	li $v0,4
	la $a0,KeyFound
	syscall
	
	j Endinsertkey
#else
ELSE:
	blt $t1,$t0,If
	j Else

#if keys<N
If:
	#calling hashfucntion
	jal hashfunction
	
	#hash[position]=k;
	sw $a2,hash($v1)
	
	#keys++;
	addi $t1,$t1,1
	j Endinsertkey
Else:
	
	li $v0,4
	la $a0,FullHash
	syscall	
Endinsertkey:
	#restoring register $ra from the stack
	lw $ra,4($sp)
	addi $sp,$sp,4
	jr $ra
	


	


#int hashfucntion(int[] hash,int k)								
hashfunction:
	#position=k%n;	
	rem $t5,$a2,$t0		
	
	#multiplying x4 because table contains integers
	mul $a1,$t5,4
	
	#$t6=hash[position]
	lw $t6,hash($a1)							
While:	
	#if hash[position]=0 goto EXIT
	beq $t6,0,EXIT
	
	#position++
	addi $t5,$t5,1
	
	#position %=N;	
	rem $t5,$t5,$t0 							
	
	mul $a1,$t5,4	
	
	#$t6=hash[position]								
	lw $t6,hash($a1)										
	
	j While
EXIT:	
	#storing position in $v1
	mul $v1,$t5,4
	jr $ra											
													
														

																																


#int findkey(int[] hash, int k)
findkey:	
	
	#i=0;
	li $t3,0 
	
	#found=0;
	li $t4,0 
	
	#position=k%n;
	rem $t5,$a2,$t0 
while:
	
	#if i>=N go to exitwhile
	bge $t3,$t0,exitwhile
	#if found==0 go to exitwhile
	bne $t4,$zero,exitwhile
	
	#i++
	addi $t3,$t3,1
	
	#multiplying x4 because table contains integers
	mul $a1,$t5,4
	
	#$t6=hash[position]
	lw $t6,hash($a1)
	
	
	beq $t6,$a2,Iff
	j Elsee

#if hash[position]==k
Iff:
	#found=1;
	addi $t4,$t4,1
	j exitwhile

#else
Elsee:
	#position ++
	addi $t5,$t5,1
	
	#position%=N;
	rem $t5,$t5,$t0
	
	j while
												
																
exitwhile:
	
	beq $t4,1,iF
	j else

#if found==1
iF:	
	#position is stored in #v1
	mul  $v1,$t5,4
	j Endfindkey

#else
else:
	li $v1,-1

Endfindkey:																								
	jr $ra																															
																																								
																																																
																																																																																																																						
																																																																																																																																																							
																																																																																																																																																																																								
																																																																																																								
#void displaytable(int [] hash)																																																																																																																																		
displaytable:
	
	#i=0;
	li $t3,0  
	
	#println("\npos    key\n");
	li $v0,4
	la $a0,PosKey
	syscall
Loop:	
	#if i>=$t0 goto exitloop
	bge $t3,$t0,exitloop
	
	#$t5=hash[i]
	lw $t5,($a1)
	
	#leaving empty space
	li $v0,4
	la $a0,Empty
	syscall										
	
	#printing i
	li $v0,1
	move $a0,$t3
	syscall
	
	#leaving empty space between i and hash[i]
	li $v0,4
	la $a0,Empty2
	syscall										
	
	#printing hash[i]
	li $v0,1
	move $a0,$t5
	syscall
	
	#changing line
	li $v0,4
	la $a0,changeline
	syscall										
	
	#going to the next position of the hash table
	addi $a1,$a1,4
	#i++
	addi $t3,$t3,1
	j Loop

#back to main
exitloop:
	jr $ra
	
	
	
	
	.data

N:.word 10
keys:.word 0
hash:.space 40	
Menu:.asciiz "\n Menu\n"
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
PosKey:.asciiz"\npos    key\n\n"
Empty:.asciiz"  "
Empty2:.asciiz"    "
changeline:.asciiz"\n"

