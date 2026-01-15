extends Node
class_name InputController

var input: InputList
var device = false
const InputActionsMasks = [
	"TAG", "SPECIAL", "JUMP", "ACTION", "CHARACTER TOGGLE DOWN",
	"CHARACTER TOGGLE UP", "START/PAUSE", "SHOW MAP",
]
const HeldActionsMasks = [
	"TAG", "SPECIAL", "JUMP", "ACTION", "CHARACTER TOGGLE DOWN",
	"CHARACTER TOGGLE UP", "START/PAUSE", "SHOW MAP",
]
const DirsMasks = ["MOVE LEFT", "MOVE RIGHT", "MOVE UP", "MOVE DOWN"]
const Dirs2Masks = ["LEFT", "RIGHT", "UP", "DOWN"]
const LookDirsMasks = ["LOOK LEFT", "LOOK RIGHT", "LOOK UP", "LOOK DOWN"]

var InputActions: Array = []
var HeldActions: Array = []
var dirs: Array = []
var dirs2: Array = []
var look_dirs: Array = []

func _ready():
	await Settings.initialized
	refresh_controls(0)


##p is which player: 0 for player 1
func refresh_controls(p):
	InputActions = []
	HeldActions = []
	dirs = []
	dirs2 = []
	look_dirs = []
	var con: ControlScheme
	if p: con = Settings.controls_p2
	else: con = Settings.controls_p1
	device = con.device
	for i in InputActionsMasks:
		InputActions.append(con.keybinds[i])
	for i in HeldActionsMasks:
		HeldActions.append(con.keybinds[i])
	for i in DirsMasks:
		dirs.append(con.keybinds[i])
		
	for i in Dirs2Masks:
		dirs2.append(con.keybinds[i])
	for i in LookDirsMasks:
		look_dirs.append(con.keybinds[i])


func get_input(last: InputList) -> InputList:
	input = InputList.new()
	
	var dirs_to_nums = []
	
	if dirs[0] is Array:
		input.direction.x = Input.get_joy_axis(device, dirs[0][0])
		input.direction.y = Input.get_joy_axis(device, dirs[2][0])
		if abs(input.direction).length() < 0.02: input.direction = Vector2.ZERO
	else:
		for i in dirs:
			dirs_to_nums.append(input_to_bin(i))
		input.direction = Vector2(-dirs_to_nums[0] + dirs_to_nums[1], -dirs_to_nums[2] + dirs_to_nums[3])
	
	var in_dir2: Vector2
	if dirs2[0] is Array:
		in_dir2.x = Input.get_joy_axis(device, dirs2[0][0])
		in_dir2.y = Input.get_joy_axis(device, dirs2[2][0])
		if abs(input.direction).length() < 0.01: input.direction = Vector2.ZERO
	else:
		for i in dirs2:
			dirs_to_nums.append(input_to_bin(i))
		in_dir2 = Vector2(-dirs_to_nums[0]+dirs_to_nums[1],-dirs_to_nums[2]+dirs_to_nums[3])
	if in_dir2.length() > input.direction.length():
		input.direction = Vector2(-dirs_to_nums[0] +dirs_to_nums[1], -dirs_to_nums[2] +dirs_to_nums[3])
	
	for n in InputActions.size():
		if not last.actions.has(str(InputActionsMasks[n], " HELD")):
			if input_to_bin(InputActions[n]):
				input.actions.append(InputActionsMasks[n])
	for n in HeldActions.size():
		if input_to_bin(HeldActions[n]):
			input.actions.append(str(HeldActionsMasks[n], " HELD"))
	
	last.queue_free()
	return input


##Returns 1 or 0 based on given Input from controller or keyboard.
##"i" is the enumerator value of the key or button to poll
##"d" is optionally the joypad id or -2 for keyboard
func input_to_bin(i, d:int = -1) -> int:
	var out = 0

	if d != -1:
		if d == -2 and Input.is_key_pressed(i): out = 1
		if d != -2 and Input.is_joy_button_pressed(d, i): out = 1
	elif device is int:
		if Input.is_joy_button_pressed(device, i): out = 1
	else:
		if Input.is_key_pressed(i): out = 1
	
	return out
