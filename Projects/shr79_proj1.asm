# Syed Hadi Rizvi
# shr79

# set to 1 to show solution after generating puzzle, so the grader can properly test.
# (and so can you, really)
.eqv GRADER_MODE 1

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

.eqv INVALID -1
.eqv RED      0
.eqv GREEN    1
.eqv BLUE     2
.eqv YELLOW   3
.eqv ORANGE   4
.eqv PURPLE   5

.eqv MIN_COLORS  3
.eqv MAX_COLORS  6
.eqv PUZZLE_SIZE 4
.eqv NUM_TRIES   10

.eqv INPUT_SIZE 100

.data
	color_names:  .asciiz "rgbyop"    # indexed by color constants

	playing:      .word 0             # bool - keep playing?
	player_won:   .word 0             # bool - did they win?
	num_colors:   .word 0             # how many colors (difficulty level)
	tries_left:   .word 0            # how many tries the player has remaining

	str_input:    .byte 0:INPUT_SIZE  # string input buffer

	puzzle:       .byte 0:PUZZLE_SIZE # the solution
	guess:        .byte 0:PUZZLE_SIZE # the player's guess
	puzzle_cross: .byte 0:PUZZLE_SIZE # used by check_guess
	guess_cross:  .byte 0:PUZZLE_SIZE # "
.text

# -------------------------------------
.global main
main:
	# while playing...
	_loop:
		jal ask_for_num_colors
		jal generate_puzzle
		jal show_solution_to_grader
		jal play_game
		jal game_over_message
		jal ask_play_again
	lw  t0, playing
	bne t0, 0, _loop

	# exit
	li v0, 10
	syscall

# -------------------------------------
# prompts user for number of colors and sets num_colors to a value in the range
# [MIN_COLORS, MAX_COLORS].
ask_for_num_colors:

	_loop:
		print_str "How many colors?: "
		li v0, 5
		syscall
		move t0, v0
		blt t0, MIN_COLORS, _loop
		bgt t0, MAX_COLORS, _loop
	
	sw t0, num_colors
			
jr ra

# -------------------------------------
# fills puzzle with PUZZLE_SIZE colors, randomly selected from the range [0 .. num_colors).
generate_puzzle:

	li t0, 0
	
	_loop:
		lw a1, num_colors
		li v0, 42
		syscall
		
      		sb v0, puzzle(t0)
		
		add t0, t0, 1
		blt t0, PUZZLE_SIZE, _loop
	
		
jr ra

# -------------------------------------
# if we're in grader mode, show the puzzle solution.
show_solution_to_grader:
push ra

	beq, zero, GRADER_MODE, _break
	print_str "(SOLUTION: "
	jal show_solution
	print_str ")\n"
	pop ra
	
_break:
pop ra
jr ra
# -------------------------------------
# show the puzzle solution as text (e.g. rggb)
show_solution:
	li t0, 0
	
	_loop:
		lb t1, puzzle(t0)
		
		lb a0, color_names(t1)
	
		li v0, 11
		syscall
		
		add t0, t0, 1
		blt t0, PUZZLE_SIZE, _loop

jr ra

# -------------------------------------
# play one round of the game.
play_game:
push ra

li t0, 0
sw t0, player_won
li t0, NUM_TRIES
sw t0, tries_left
li s0, 0
	_loop:
		jal game_prompt
		beq v0, PUZZLE_SIZE, _convert
		print_str "Enter "
		li a0, PUZZLE_SIZE
		li v0, 1
		syscall
		print_str " letters.\n"
		j _loop
		
		_convert:
			jal convert_guess
			bne v0, 1, _invalid
			jal check_guess
			
			lw t0, player_won
			beq t0, 0, _decrease
			j _break
		
		_invalid:
			print_str "Invalid guess.\n"
			j _loop
		
		_decrease:
			lw t0, tries_left
			sub t0, t0, 1
			sw t0, tries_left
			bgt t0, zero, _loop
			j _break
			
_break:
pop ra
jr ra

# -------------------------------------
# shows how many tries remain and gets the user's guess.
# returns the length of the user's input.
game_prompt:
push ra
	print_str "("
	lw a0, tries_left
	li v0, 1
	syscall
	
	print_str " tries remaining) Enter your guess: "
	jal read_line
	
pop ra
jr  ra

# -------------------------------------
# loops over str_input and converts the characters to colors, filling in the "guess" array.
# assumes length of str_input == PUZZLE_SIZE.
# returns true (1) if it was a valid guess, and false (0) if not.
convert_guess:
push ra
push s0

	_loop:
		lb t1, str_input(s0)
		move a0, t1
		jal char_to_color #color is now in v0
	
		lw t3, num_colors
		beq v0, INVALID, _false
		blt v0, t3, _store
		li v0, 0
		j _break
		
		_false:
			li v0, 0
			j _break
		
		_store:
			sb v0, guess(s0)
		
		add s0, s0, 1
		blt s0, PUZZLE_SIZE, _loop
li v0, 1
j _break

_break:
pop s0
pop ra
jr ra
		


# -------------------------------------
# int char_to_color(char c)
# returns the character constant for the given character, or INVALID if it's invalid.
char_to_color:
	move t0, a0
	
	beq t0, 'r', _red
	beq t0, 'R', _red
	beq t0, 'g', _green
	beq t0, 'G', _green
	beq t0, 'b', _blue
	beq t0, 'B', _blue
	beq t0, 'y', _yellow
	beq t0, 'Y', _yellow
	beq t0, 'o', _orange
	beq t0, 'O', _orange
	beq t0, 'p', _purple
	beq t0, 'P', _purple
	j _default
	
	_red:
		li v0, RED
		j _break
	_green:
		li v0, GREEN
		j _break
	
	_blue:
		li v0, BLUE
		j _break
	
	_yellow:
		li v0, YELLOW
		j _break
	_orange:
		li v0, ORANGE
		j _break
	
	_purple:
		li v0, PURPLE
		j _break
	
	_default:
		li v0, INVALID
		j _break

	
_break:
jr ra

# -------------------------------------
# shows win/lose message (and the solution if they lost).
game_over_message:
push ra
	lw t0, player_won
	bne t0, zero, _win
	print_str "Sorry, you're out of guesses...\nThe solution was: "
	jal show_solution
	print_str "\n"
	j _break
	
	_win:
		print_str "That's right! You win!\n"
		j _break
	
_break:	
pop ra
jr ra

# -------------------------------------
# ask if they want to play again, and sets the 'playing' variable accordingly
ask_play_again:
	
	_loop:
		print_str "Play again (y/n)?: "
		li v0, 12
		syscall
		print_str "\n"
		move t0, v0
		beq t0, 'y', _yes
		beq t0, 'Y', _yes
		beq t0, 'n', _no
		beq t0, 'N', _no
		j _default
		
		
		_yes:
			li t1, 1
			sw t1, playing
			j _break
		
		_no:
			li t1, 0
			sw t1, playing
			j _break
		
		_default:
			print_str "\n"
			j _loop

_break:
jr ra

# --------------------------------------------------------------------------------------------------
# DO NOT CHANGE ANYTHING BELOW THIS LINE! THERE IS NO REASON FOR YOU TO CHANGE ANYTHING BELOW!
# --------------------------------------------------------------------------------------------------

# -------------------------------------
# void check_guess()
# compares guess to puzzle. if they match exactly, sets player_won to true (1).
# otherwise, shows how many exact and inexact matches there are.
# this algorithm is frustratingly subtle and complicated, for such a simple game...
check_guess:
push s0
	# reset the cross arrays
	li t9, 0
	_clear_loop:
		sb zero, puzzle_cross(t9)
		sb zero, guess_cross(t9)
	add t9, t9, 1
	blt t9, PUZZLE_SIZE, _clear_loop

	# count of matches = 0
	li s0, 0

	# 1. find exact matches
	# for i:t9 = 0 to PUZZLE_SIZE
	li t9, 0
	_exact_loop:
		# if guess[i] == puzzle[i],
		lb t0, guess(t9)
		lb t1, puzzle(t9)
		bne t0, t1, _differ
			# cross both off
			li   t0, 1
			sb   t0, puzzle_cross(t9)
			sb   t0, guess_cross(t9)
			# count++
			add  s0, s0, 1
		_differ:
	add t9, t9, 1
	blt t9, PUZZLE_SIZE, _exact_loop

	# if all places guessed right, they win!
	beq s0, PUZZLE_SIZE, _win

	# otherwise, print count of exact matches
	print_str "Right color, right place: "
	move a0, s0
	li v0, 1
	syscall
	print_str "; "

	# 2. find inexact matches.
	# count = 0
	li s0, 0

	# for i:t9 = 0 to PUZZLE_SIZE
	li t9, 0
	_inexact_loop:
		# if not guess_cross[i] (if we haven't already looked at this guess color),
		lb  t0, guess_cross(t9)
		bne t0, 0, _next_i
			# for j:t8 = 0 to PUZZLE_SIZE
			li t8, 0
			_nested:
				# if not puzzle_cross[j] AND guess[i] == puzzle[j],
				lb t0, puzzle_cross(t8)
				bne t0, 0, _next_j
				lb t0, guess(t9)
				lb t1, puzzle(t8)
				bne t0, t1, _next_j
					# cross off guess[i] and puzzle[j]
					li   t0, 1
					sb   t0, puzzle_cross(t8)
					sb   t0, guess_cross(t9)
					# count++
					add  s0, s0, 1
				_next_j:
			add t8, t8, 1
			blt t8, PUZZLE_SIZE, _nested
		_next_i:
	add t9, t9, 1
	blt t9, PUZZLE_SIZE, _inexact_loop

	# print count of inexact matches
	print_str "right color, wrong place: "
	move a0, s0
	li v0, 1
	syscall
	print_str "\n"
	j _return

_win:
	# player_won = true
	li t0, 1
	sw t0, player_won
_return:
pop s0
jr ra

# -------------------------------------
# int strlen(char* str)
# returns number of characters in 0-terminated string.

strlen:
	li v0, 0
	_loop:
		lb  t0, (a0)
		beq t0, 0, _return
		add v0, v0, 1
		add a0, a0, 1
	j _loop
_return:
jr ra

# -------------------------------------
# int read_line()
# reads a line of text into str_input, removing the trailing \n (if any).
# returns the length of the text.

read_line:
push ra
	# read_string(str_input, INPUT_SIZE)
	la a0, str_input
	li a1, INPUT_SIZE
	li v0, 8
	syscall

	# len = strlen(str_input)
	la a0, str_input
	jal strlen

	# if len != 0 && str_input[len - 1] == '\n'
	beq v0, 0, _return
	sub t0, v0, 1
	lb  t1, str_input(t0)
	bne t1, '\n', _return

		# len--
		sub v0, v0, 1
		# str_input[len] = 0
		sb zero, str_input(v0)

	# return len
_return:
pop ra
jr  ra
