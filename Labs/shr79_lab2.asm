# Syed Hadi Rizvi
# shr79

# preserves a0, v0
.macro print_str %str
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

.data
    display: .word 0
    operation: .byte 0
.text

.globl main
main:
	 print_str "Hello! Welcome!\n"
	 _loop:
	 	li v0, 1
	 	lw a0, display
	 	syscall
	 	
	 	print_str "\nOperation (=,+,-,*,/,c,q): "
	 	li v0, 12
	 	syscall
	 	sb v0, operation
	 
		lb  t0, operation
		beq t0, 'q', _quit
		beq t0, 'c', _clear
		beq t0, '+', _add
		beq t0, '-', _subtract
		beq t0, '*', _multiply
		beq t0, '/', _divide
		beq t0, '=', _equals
		j   _default

		_add:
			print_str "\nValue: "
			li v0, 5
			syscall
			lw t0, display
			add t1, t0, v0
			sw t1, display
			j _break
			
	
		_subtract:
			print_str "\nValue: "
			li v0, 5
			syscall
			lw t0, display
			sub t1, t0, v0
			sw t1, display
			j _break
			
			
		_multiply:
			print_str "\nValue: "
			li v0, 5
			syscall
			lw t0, display
			mul t1, t0, v0
			sw t1, display
			j _break
			
		_divide:
			print_str "\nValue: "
			li v0, 5
			syscall
			lw t0, display
			bne t0, 0, _else
			print_str "\nAttempting to divide by 0!"
			j _endif
			_else:	
				print_str "\nValid Division!"
				div t1, t0, v0
				sw t1, display
				j _break
			_endif:
				bne t0, 0, _else
			
		_equals:
			print_str "\nValue: "
			li v0, 5
			syscall
			sw v0, display
			j _break
				
		_quit:
			li v0, 10
			syscall
	
		# case 'c'
		_clear:
			print_str "clear\n"
			sw zero, display
			j _break
	
		# default:
		_default:
			print_str "Huh?\n"
	
	_break:
	 	
     		j _loop
     	j _loop
