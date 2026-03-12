extends Node

# So I'm sure there's a much better way to do this cuz we already have the input map from base Godot
# 	but the method I used for handling multiple players (the player_index variable and the functions
# 	Input.get_joy_axis and Input.is_joy_button_pressed) require numbered indicies instead of string
# 	names like the built in mapper uses. Not to mention the version I have now distinguishes between
# 	'axis' and 'button' which is what this script intends to simplify
# An alternative is the 2nd thing I sent in the technical-jargon chanel in the discord, which just
# 	fixes this exact problem as a built-in from the asset library.

# Joy Button
const dash_button = 0		# A button
const ability_2 = 1			# B button
const ability_1 = 2			# X button
const ultimate = 3			# Y button

const open_menu = 6			# Start menu
const navigate_up = 11		# D-pad up
const navigate_down = 12	# D-pad down
const navigate_left = 13	# D-pad left
const navigate_right = 14	# D-pad right

const select_menu = 0	# Redundant but menu specific
const navigate_back = 1	# Redundant but menu specific


# Joy Axis
const move_x = 0			# Left stick x-axis
const move_y = 1			# Left stick y-axis
const aim_x = 2				# Right stick x-axis
const aim_y = 3				# Right stick y-axis
const dash_trigger = 4		# Left trigger (yes, triggers have sensitivity)
const attack = 5			# Right trigger (yes, triggers have sensitivity)
