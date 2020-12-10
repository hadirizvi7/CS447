# Syed Hadi Rizvi
# shr79

# preserves a0, v0
.macro print_str %str
	# DON'T PUT ANYTHING BETWEEN .macro AND .end_macro!!
	.data
	print_str_message: .asciiz %str
	.text
	push a0
	push v0
	la a0, print_str_message
	li v0, 4
	syscall
	pop v0
	pop a0
.end_macro

# -------------------------------------------
.eqv ARR_LENGTH 5
.data
	arr: .word 100, 200, 300, 400, 500
	message: .asciiz "testing!"
.text
# -------------------------------------------
.globl main
main:

	jal input_arr
	jal print_arr
	
	la a0, message
	jal print_chars
	
	li v0, 10
	syscall
# -------------------------------------------
  input_arr:
  
      _loop:
      	print_str "enter value: "
      	
      	li v0, 5
      	syscall
      	
      	#move s0, v0 (move v0 into s0)
      	la t1, arr
      	mul t2, t0, 4
      	add t1, t1, t2
      	sw v0, (t1)
      	
      	
      	print_str "\n"
      	add t0, t0, 1
      	blt t0, ARR_LENGTH, _loop
      jr ra
# -------------------------------------------
  print_arr:
      li t0, 0
      _loop:
      	print_str "arr["
      	
      	la t1, arr
      	mul t2, t0, 4
      	add t1, t1, t2
      	lw t2, (t1)
      	
      	li v0, 1
      	move a0, t0
      	syscall
      	print_str "] = "
      	
      	li v0, 1
      	move a0, t2
      	syscall
      	
      	print_str "\n"
      	add t0, t0, 1
      	blt t0, ARR_LENGTH, _loop
      jr ra
# -------------------------------------------
  print_chars:      
      move t0, a0
      li t1, 0
      
      print_char:
      	lb t2, (t0)
      	beq t2, 0, return
      	move a0, t2
      	li v0, 11
      	syscall
      	
      	addi t1, t1, 1
      	addi t0, t0, 1
      	print_str "\n"
      	
      	j print_char
      
      return:
      	jr ra
