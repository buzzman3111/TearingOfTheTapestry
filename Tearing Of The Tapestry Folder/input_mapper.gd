extends Resource

# So I wrote this thing BEFORE I read all the built-in variables for the 
# 	functions that require joy buttons/axis so we don't use this in the 
# 	CharacterBase script anymore xD
# However, I'm keeping this since it can be used for keybind settings
# 	or repurposed into general settings later 🍔

# Joy Button
const dash_button = 0 		# A button
const ability_2 = 1 		# B button
const ability_1 = 2 		# X button
const ultimate = 3 			# Y button

const open_menu = 6 		# Start menu
const navigate_up = 11 		# D-pad up
const navigate_down = 12	# D-pad down
const navigate_left = 13	# D-pad left
const navigate_right = 14	# D-pad right

const select_menu = 0 		# Redundant but menu specific
const navigate_back = 1		# Redundant but menu specific


# Joy Axis
const move_x = 0 			# Left stick x-axis
const move_y = 1 			# Left stick y-axis
const aim_x = 2 			# Right stick x-axis
const aim_y = 3 			# Right stick y-axis
const dash_trigger = 4 		# Left trigger (yes, triggers have push range)
const attack = 5 			# Right trigger (yes, triggers have push range)
