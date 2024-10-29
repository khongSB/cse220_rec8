######### Kendrick Hong ##########
######### 114468129 ##########
######### keyhong ##########
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text
.macro malloc(%reg)													# does not preserve $v0
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	move $a0, %reg
	li $v0, 9
	syscall
	lw $a0, 0($sp)
	addi $sp, $sp, 4
.end_macro
.macro printService(%reg, %imm)									# 1: int  4: str  11: char
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	move $a0, %reg
	li $v0, %imm
	syscall
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
.end_macro
.macro equalsString(%reg1, %reg2)									# does not preserve $v0
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	move $t0, %reg1
	move $t1, %reg2
	equalsString.loop:
		lb $t2, 0($t0)
		lb $t3, 0($t1)
		bne $t2, $t3, equalsString.false
		beqz $t2, equalsString.true
		addTo($t0, 1)
		addTo($t1, 1)
		j equalsString.loop
	equalsString.false:
		li $v0, 0
		j equalsString.finish
	equalsString.true:
		li $v0, 1
	equalsString.finish:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
.end_macro
.macro equalsStrDoubleton(%reg1, %reg2, %reg3, %reg4)				# does not preserve $v0
	equalsString(%reg1, %reg3)
	bnez $v0, eqsd.firstMatch
		equalsString(%reg1, %reg4)
		bnez $v0, eqsd.outerMatch
		j eqsd.false
	eqsd.firstMatch:
		equalsString(%reg2, %reg4)
		bnez $v0, eqsd.true
		j eqsd.false
	eqsd.outerMatch:
		equalsString(%reg2, %reg3)
		bnez $v0, eqsd.true
		j eqsd.false
	eqsd.true:
		li $v0, 1
		j eqsd.finish
	eqsd.false:
		li $v0, 0
	eqsd.finish:
.end_macro
.macro addTo(%reg, %imm)
	addi %reg, %reg, %imm
.end_macro
.globl create_network
create_network:
	blez $a0, create_network.failure								# input validation
	blez $a1, create_network.failure								# |
	add $t0, $a0, $a1												# calculating memory to allocate
	sll $t0, $t0, 2													# |
	addTo($t0, 16)													# |
	malloc($t0)
	sw $a0, 0($v0)													# setting up the new network
	sw $a1, 4($v0)
	addTo($t0, -16)
	srl $t0, $t0, 2
	move $t1, $0
	addi $t2, $v0, 8
	create_network.initLoop:										# | $t0:end  $t1:begin  $t2:address
		beq $t1, $t0, create_network.return
		sw $0, 0($t2)
		addTo($t2, 4)
		addTo($t1, 1)
		j create_network.initLoop
	create_network.failure:
		li $v0, -1
	create_network.return:
		jr $ra

.globl add_person
add_person:
	lw $t0, 0($a0)													# maxNodes
	lw $t1, 8($a0)													# numNodes
	beq $t0, $t1, add_person.failure
	lb $t2, 0($a1)
	beqz $t2, add_person.failure
	addi $t3, $a0, 16
	add_person.verifyLoop:											# $t3:address
		lw $t4, 0($t3)												# load otherNode address
		beqz $t4, add_person.success
		addTo($t4, 4)
		equalsString($a1, $t4)
		bnez $v0, add_person.failure
		addTo($t3, 4)
		j add_person.verifyLoop
	add_person.success:
	move $t5, $t3													# set $t5 to address of blank element
	li $t2, 4
	move $t3, $a1
	add_person.countNameLen:										# $t2:count  $t3:address  $t4:char
		lb $t4, 0($t3)
		addTo($t2, 1)
		addTo($t3, 1)
		beqz $t4, add_person.malloc
		j add_person.countNameLen
	add_person.malloc:
	malloc($t2)
	addTo($t2, -5)
	sw $t2, 0($v0)
	addi $t2, $v0, 4
	move $t3, $a1
	add_person.addName:												# $t2:newAddr  $t3:oldAddr  $t4:char
		lb $t4, 0($t3)
		sb $t4, 0($t2)
		beqz $t4, add_person.finish
		addTo($t3, 1)
		addTo($t2, 1)
		j add_person.addName
	add_person.finish:
		sw $v0, 0($t5)												# store node in array
		addTo($t1, 1)												# update numNodes
		sw $t1, 8($a0)												# |
		move $v0, $a0
		li $v1, 1
		jr $ra
	add_person.failure:
		li $v0, -1
		li $v1, -1
		jr $ra

.globl get_person
get_person:															# preserves everything except $v0, $v1
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	move $t0, $0
	lw $t1, 8($a0)
	addi $t2, $a0, 16
	get_person.loop:
		beq $t0, $t1, get_person.failure
		lw $t3, 0($t2)
		addTo($t3, 4)
		equalsString($t3, $a1)
		bnez $v0, get_person.success
		addTo($t0, 1)
		addTo($t2, 4)
		j get_person.loop
	get_person.failure:
		li $v0, -1
		li $v1, -1
		j get_person.return
	get_person.success:
		addTo($t3, -4)
		move $v0, $t3
		li $v1, 1
		j get_person.return
	get_person.return:
		lw $t0, 0($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		lw $t3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
		
.globl add_relation
add_relation:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	equalsString($a1, $a2)											# same name
	bnez $v0, add_relation.failure									# |
	bltz $a3, add_relation.failure									# class < 0
	li $t0, 3														# class > 3
	bgt $a3, $t0, add_relation.failure								# |
	lw $t0, 12($a0)													# numEdges
	lw $t1, 4($a0)													# maxEdges
	beq $t0, $t1, add_relation.failure								# capacity reached
	li $t8, -1
	jal get_person													# check person1
	beq $v1, $t8, add_relation.failure								# |
	sw $v0, 4($sp)													# save address of person1 in stack
	move $t2, $a1
	move $a1, $a2
	jal get_person													# check person2
	beq $v1, $t8, add_relation.failure								# |
	sw $v0, 8($sp)													# save address of person2 in stack
	move $a1, $t2
	lw $t2, 0($a0)
	sll $t2, $t2, 2
	addTo($t2, 16)
	add $t2, $a0, $t2
	add_relation.verifyLoop:										# $t2:address
		lw $t3, 0($t2)
		beqz $t3, add_relation.success
		lw $t4, 0($t3)
		addTo($t4, 4)
		lw $t5, 4($t3)
		addTo($t5, 4)
		equalsStrDoubleton($a1, $a2, $t4, $t5)
		bnez $v0, add_relation.failure
		addTo($t2, 4)
		j add_relation.verifyLoop
	add_relation.success:
		li $t9, 12
		malloc($t9)
		lw $t6, 4($sp)
		lw $t7, 8($sp)
		sw $t6, 0($v0)
		sw $t7, 4($v0)
		sw $a3, 8($v0)
		sw $v0, 0($t2)
		addTo($t0, 1)
		sw $t0, 12($a0)
		move $v0, $a0
		li $v1, 1
		j add_relation.return
	add_relation.failure:
		li $v0, -1
		li $v1, -1
		j add_relation.return
	add_relation.return:
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	jr $ra

.macro alreadyAdded(%nodeAddr, %listAddr, %end)					# does not preserve $v0
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	move $s0, $0
	move $s1, %listAddr
	alreadyAdded.loop:
		beq $s0, %end, alreadyAdded.false
		lw $s2, 0($s1)												# load otherNode*
		beq $s2, %nodeAddr, alreadyAdded.true
		addTo($s0, 1)
		addTo($s1, 4)
		j alreadyAdded.loop
	alreadyAdded.true:
		li $v0, 1
		j alreadyAdded.finish
	alreadyAdded.false:
		li $v0, 0
	alreadyAdded.finish:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
.end_macro
.macro getEdgeFriend(%edge, %node)									# does not preserve $v0
	addi $sp, $sp, -8												# %edge is actually [edge]*
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	lw $s0, 0(%edge)
	lw $s0, 8($s0)
	li $s1, 1
	bne $s0, $s1, gef.invalid
	lw $s0, 0(%edge)
	lw $s0, 0($s0)
	bne $s0, %node, gef.checkSecond
		lw $v0, 0(%edge)
		lw $v0, 4($v0)
		j gef.finish
	gef.checkSecond:
		lw $s1, 0(%edge)
		lw $s1, 4($s1)
		bne $s1, %node, gef.invalid
			move $v0, $s0
			j gef.finish
	gef.invalid:
		li $v0, -1
	gef.finish:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
.end_macro

.globl get_distant_friends
get_distant_friends:												# $a0:network*  $a1:string*
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	jal get_person
	bltz $v1, get_distant_friends.DNE
	move $t1, $v0
	lw $t0, 8($a0)
	sll $t0, $t0, 2
	malloc($t0)
	move $t0, $v0													# $t0:connected[]*
	sw $t1, 0($t0)													# save srcNode* as connected[0]
	lw $t9, 12($a0)													# $t9:numEdges
	li $t3, 1														# $t3:end)
	move $t4, $0													# $t4:i
	move $t5, $t0													# $t5:connected[i]*
																	# $t1:connected[i]
	move $s0, $t5													# $s0:connected[-1]*
	move $t6, $0
	lw $t7, 0($a0)
	sll $t7, $t7, 2
	addTo($t7, 16)
	add $t7, $t7, $a0
	get_distant_friends.addImmediateFriends:						# $t6:edgeIndex $t7:edge*
		beq $t6, $t9, get_distant_friends.aif.done
		getEdgeFriend($t7, $t1)
		li $t8, -1
		beq $v0, $t8, gdf.aif.next
		addTo($s0, 4)
		sw $v0, 0($s0)
		addTo($t3, 1)
		gdf.aif.next:
		addTo($t6, 1)
		addTo($t7, 4)
		j get_distant_friends.addImmediateFriends
	get_distant_friends.aif.done:
	move $s1, $s0													# $s1:[lastImmediateFriend]*
	move $s2, $0													# $s2:numDistantFriends
	gdf.adf.forPass:
		beq $t4, $t3, gdf.createList
		addTo($t4, 1)
		addTo($t5, 4)
		lw $t1, 0($t5)

		move $t6, $0
		lw $t7, 0($a0)
		sll $t7, $t7, 2
		addTo($t7, 16)
		add $t7, $t7, $a0
		gdf.adf.forEdge:
			beq $t6, $t9, gdf.adf.edgesDone
			getEdgeFriend($t7, $t1)
			li $t8, -1
			beq $v0, $t8, gdf.adf.forEdge.next
			move $t8, $v0
			alreadyAdded($v0, $t0, $t3)
			bnez $v0, gdf.adf.forEdge.next
			move $v0, $t8
			addTo($s0, 4)
			sw $v0, 0($s0)
			addTo($t3, 1)
			addTo($s2, 1)
			gdf.adf.forEdge.next:
			addTo($t6, 1)
			addTo($t7, 4)
			j gdf.adf.forEdge
		gdf.adf.edgesDone:
		j gdf.adf.forPass
	gdf.createList:
	addTo($s1, 4)													# $s1:distantConnected[]*
	move $t7, $s1													# $t7:distantConnected[i]*
	sll $s0, $s2, 2													# create array of linkedNodes
	malloc($s0)														# |
	move $s0, $v0													# $s0:linkedNodes[]*
	beqz $s2, get_distant_friends.empty
	move $t0, $0													# $t0:i
	move $t6, $s0
	gdf.createList.loop:											# $t1:node*  $t2:k  $t6:linkedNodes[i]*
		beq $t0, $s2, gdf.createList.finish
		lw $t1, 0($t7)
		lw $t2, 0($t1)
		addTo($t2, 5)
		malloc($t2)
		addTo($t2, -5)
		li $t3, -1
		addi $t4, $t1, 4
		move $t9, $v0
		gdf.createList.loop.copyString:							# $t3:i  $t4:char*  $t5:char  $t9:newChar*
			beq $t3, $t2, gdf.createList.loop.copyString.finish
			lb $t5, 0($t4)
			sb $t5, 0($t9)
			addTo($t3, 1)
			addTo($t4, 1)
			addTo($t9, 1)
			j gdf.createList.loop.copyString
		gdf.createList.loop.copyString.finish:
		sw $v0, 0($t6)
		addTo($t0, 1)
		addTo($t7, 4)
		addTo($t6, 4)
		j gdf.createList.loop
	gdf.createList.finish:
		## Connect the linkedNodes ##
		move $t7, $s1												# $t7:distantConnected[i]*
		move $t0, $s0
		li $t1, 1
		gdf.connectNodes:											# $t1:counter  $t0:linkedNodes[i]*
			beq $t1, $s2, gdf.connectNodes.done
		
			lw $t3, 0($t7)											# load node address
			lw $t3, 0($t3)											# load node k
			addi $t5, $t3, 1
			li $t4, 4
			div $t5, $t4
			mfhi $t5
			sub $t5, $t4, $t5
			div $t5, $t4
			mfhi $t5
			add $t5, $t5, $t3
			addi $t5, $t5, 1										# $t5:numBytesAfterName
			lw $t3, 0($t0)											# $t3:linkedNode*
			lw $t4, 4($t0)											# $t4:nextLinkedNode*
			add $t5, $t5, $t3										
			sw $t4, 0($t5)
			
			addTo($t1, 1)
			addTo($t0, 4)
			addTo($t7, 4)
			j gdf.connectNodes
		gdf.connectNodes.done:
		## Add null pointer to last element ##
		lw $t3, 0($t7)											# load node address
		lw $t3, 0($t3)											# load node k
		addi $t5, $t3, 1
		li $t4, 4
		div $t5, $t4
		mfhi $t5
		sub $t5, $t4, $t5
		div $t5, $t4
		mfhi $t5
		add $t5, $t5, $t3
		addi $t5, $t5, 1										# $t5:numBytesAfterName
		lw $t3, 0($t0)											# $t3:linkedNode*
		add $t5, $t5, $t3
		sw $0, 0($t5)
		lw $v0, 0($s0)	
		j get_distant_friends.return
	get_distant_friends.empty:
		li $v0, -1
		j get_distant_friends.return
	get_distant_friends.DNE:
		li $v0, -2
		j get_distant_friends.return
	get_distant_friends.return:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra
