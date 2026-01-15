extends ColorRect

const xbox_buttons = [
	["(A)", 0x00ff41], ["(B)", 0xff0000], ["(X)", 0x0059ff], ["(Y)", 0xffe017], ["BACK ◀️"], ["HOME 🏠"],
	["START ▶️"], ["L3 ◉"], ["R3 ◉"], ["[  L  ]"], ["[  R  ]"], ["D-PAD UP"], ["D-PAD DOWN"], ["D-PAD LEFT"],
	["D-PAD RIGHT"], ["◈"], ["EXTENSION PADDLE 1"], ["EXTENSION PADDLE 2"], ["EXTENSION PADDLE 3"],
	["EXTENSION PADDLE 4"], ["TOUCHPAD ▬"]
]

const p1_defaults = ["A", "D", "W", "S", "U", "K", "J", "H", "CTRL", "SPACE", "ENTER", "M", "L",
"APOSTROPHE", "P", "SEMICOLON", "NONE", "NONE", "NONE", "NONE"]
const p2_defaults = ["LEFT", "RIGHT", "UP", "DOWN", "KP 5", "KP 3", "KP 2", "KP 1", "SHIFT", "KP 0",
"KP ENTER", "KP PERIOD", "DELETE", "PAGEDOWN", "HOME", "END", "NONE", "NONE", "NONE", "NONE"]
const blank_defaults = ["NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE",
"NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE", ]
const xbox_defaults = [
	"LEFT STICK LEFT", "LEFT STICK RIGHT", "LEFT STICK UP", "LEFT STICK DOWN", "(Y)", "(B)", "(A)", "(X)",
	"[  L  ]", "[  R  ]", "START ▶️", "BACK ◀️", "RIGHT STICK LEFT", "RIGHT STICK RIGHT", "RIGHT STICK UP",
	"RIGHT STICK DOWN", "D-PAD UP", "D-PAD DOWN", "D-PAD LEFT", "D-PAD RIGHT",
]

@export var p1_controls_node: InputController
@export var p2_controls_node: InputController

var waiting: bool = false
var player: int = 1
var changing: String

var p1_hold: ControlScheme
var p2_hold: ControlScheme

var buttons_held: Array = []
var button_to_change: Button

var last_inputs: Array = []

func _ready():
	await Settings.initialized
	for b in get_child(0).get_child(3).get_children().size():
		var x = Settings.controls_p1.keybinds[get_child(0).get_child(3).get_child(b).get_child(1).text]
		if Settings.controls_p1.device is int:
			changing = get_child(0).get_child(3).get_child(b).get_child(1).text
			if x is Array: stick([null, null, x[0]])
			else:
				button_to_change = get_child(0).get_child(3).get_child(b).get_child(0)
				rename_button(["button", null, x])
		else:
			button_to_change = get_child(0).get_child(3).get_child(b).get_child(0)
			rename_button(["key", null, x])
		
		if Settings.controls_p2:
			x = Settings.controls_p2.keybinds[get_child(0).get_child(3).get_child(b).get_child(1).text]
			if Settings.controls_p2.device is int:
				changing = get_child(0).get_child(3).get_child(b).get_child(1).text
				if x is Array: stick([null, null, x[0]])
				else:
					button_to_change = get_child(0).get_child(3).get_child(b).get_child(2)
					rename_button(["button", null, x])
			else:
				button_to_change = get_child(0).get_child(3).get_child(b).get_child(2)
				rename_button(["key", null, x])
		
		changing = ""
		button_to_change = null
		

func _process(delta):
	for b in [$VBoxContainer/Device/p1, $VBoxContainer/Device/p2, $VBoxContainer/Reset,
	$VBoxContainer/Accept, $VBoxContainer/Cancel]:
		focus_press_allow(b)
	for b in get_child(0).get_child(3).get_children():
		focus_press_allow(b.get_child(0))
		focus_press_allow(b.get_child(2))
		if b.get_child(0).button_pressed:
			buttons_held.append([b.get_child(0), b.get_child(0).text])
			button_to_change = b.get_child(0)
			remap_button(b.get_child(1).text, 1)
			b.get_child(0).button_pressed = false
		elif b.get_child(2).button_pressed:
			button_to_change = b.get_child(2)
			buttons_held.append([b.get_child(0), b.get_child(0).text])
			remap_button(b.get_child(1).text, 2)
			b.get_child(2).button_pressed = false

##Adds a shortcut to whatever's focused with the "JUMP" and "START/PAUSE" actions
##and removes it from whatever's not.
##Probably not the best way to do this, but it's worked for me in the past.
func focus_press_allow(b:Button):
	if not b.shortcut:
		b.shortcut = Shortcut.new()
	if not b.has_focus():
		if b.shortcut.events != []:
			b.shortcut.events = []
		return
	
	if b.shortcut.events != []:
		wasd_menu(b)
		return
	b.shortcut = Shortcut.new()
	b.shortcut.events.resize(2)
	if Settings.controls_p1.device is int:
		b.shortcut.events[0] = InputEventJoypadButton.new()
		b.shortcut.events[0].button_index = Settings.controls_p1.keybinds["JUMP"]
		b.shortcut.events[1] = InputEventJoypadButton.new()
		b.shortcut.events[1].button_index = Settings.controls_p1.keybinds["START/PAUSE"]
	else:
		b.shortcut.events[0] = InputEventKey.new()
		b.shortcut.events[0].keycode = Settings.controls_p1.keybinds["JUMP"]
		b.shortcut.events[1] = InputEventKey.new()
		b.shortcut.events[1].keycode = Settings.controls_p1.keybinds["START/PAUSE"]

func wasd_menu(b:Button):
	var menu_dirs = [
		[[Settings.controls_p1.keybinds["UP"],Settings.controls_p1.keybinds["MOVE UP"]], SIDE_TOP],
		[[Settings.controls_p1.keybinds["DOWN"],Settings.controls_p1.keybinds["MOVE DOWN"]], SIDE_BOTTOM],
		[[Settings.controls_p1.keybinds["LEFT"],Settings.controls_p1.keybinds["MOVE LEFT"]], SIDE_LEFT],
		[[Settings.controls_p1.keybinds["RIGHT"],Settings.controls_p1.keybinds["MOVE RIGHT"]], SIDE_RIGHT],
	]
	
	for n in menu_dirs:
		for f in n[0]:
			if f is Array: return
			if not last_inputs.has(f):
				if p1_controls_node.input_to_bin(f) and b.find_valid_focus_neighbor(n[1]):
					b.find_valid_focus_neighbor(n[1]).grab_focus()
			
			if p1_controls_node.input_to_bin(f): last_inputs.append(f)
			if p1_controls_node.input_to_bin(f) == 0 and last_inputs.has(f):
				last_inputs.erase(f)
			

func remap_button(b: String, p: int):
	if not p1_hold:
		p1_hold = Settings.controls_p1.duplicate(true)
		if Settings.controls_p2: p2_hold = Settings.controls_p2.duplicate(true)
	get_child(1).visible = true
	var windo = get_child(1).get_child(0).get_child(0)
	waiting = true
	changing = b
	player = p
	windo.get_child(1).text = changing


##Based on an InputEvent, returns: 
##[event_type:String, device_id:int(false bool for keyboard), button/axis/key:int]
func parse_input_event(ev: InputEvent) -> Array:
	var ans = ["button", ev.device]
	if ev is InputEventJoypadButton: ans.append(ev.button_index)
	elif ev is InputEventJoypadMotion:
		ans.append(ev.axis)
		ans[0] = "stick"
	elif ev is InputEventKey:
		ans[0] = "key"
		ans[1] = -2
		ans.append(ev.keycode)
	
	return ans

func _input(event):
	if !waiting or !event.is_pressed() or event is InputEventGesture or event is InputEventMouse: return
	if event is InputEventScreenDrag or event is InputEventMIDI or event is InputEventScreenTouch: return
	
	var ev: Array = parse_input_event(event)
	
	if ev[0] == "stick" and InputController.InputActionsMasks.has(changing): return
	if ev[2] == 4194305 and ev[0] == "key":
		get_child(1).visible = false
		waiting = false
		return
	
	var current_device = Settings.controls_p1.device
	var current_device2
	if Settings.controls_p1.device is bool: current_device = -2
	if Settings.controls_p2:
		current_device2 = Settings.controls_p2.device
		if Settings.controls_p2.device is bool: current_device2 = -2
	
	if changing == "device":
		if player == 1:
			if current_device == ev[1]: return
			Settings.controls_p1 = ControlScheme.new()
			if ev[1] != -2:
				Settings.controls_p1.keybinds = ControlScheme.DEFAULT_J.duplicate()
				for b:int in get_child(0).get_child(3).get_children().size():
					get_child(0).get_child(3).get_child(b).get_child(0).text = xbox_defaults[b]
			else:
				Settings.controls_p1.keybinds = ControlScheme.DEFAULT_K.duplicate()
				for b:int in get_child(0).get_child(3).get_children().size():
					get_child(0).get_child(3).get_child(b).get_child(0).text = p1_defaults[b]
			if ev[1] == -2: Settings.controls_p1.device = false
			else: Settings.controls_p1.device = ev[1]
		elif player == 2:
			if current_device2 == ev[1]: return
			Settings.controls_p2 = ControlScheme.new()
			if ev[1] != -2:
				Settings.controls_p2.keybinds = ControlScheme.DEFAULT_J.duplicate()
				for b:int in get_child(0).get_child(3).get_children().size():
					get_child(0).get_child(3).get_child(b).get_child(0).text = xbox_defaults[b]
			else:
				Settings.controls_p2.keybinds = ControlScheme.DEFAULT_K2.duplicate()
				for b:int in get_child(0).get_child(3).get_children().size():
					get_child(0).get_child(3).get_child(b).get_child(0).text = p2_defaults[b]
			if ev[1] == -2: Settings.controls_p2.device = false
			else: Settings.controls_p2.device = ev[1]
		
		get_child(1).visible = false
		waiting = false
		return
	
	if player == 1:
		if current_device != ev[1]: return
		
		if ev[0] == "stick":
			var stik: Array = stick(ev)
			if stik == []: return
			for i in stik:
				Settings.controls_p1.keybinds[i[0]] = i[1]
			
		else: Settings.controls_p1.keybinds[changing] = ev[2]
		
		
	elif player == 2:
		if current_device2 != ev[1]: return
			
		if ev[0] == "stick":
			var stik: Array = stick(ev)
			if stik == []: return
			for i in stik:
				Settings.controls_p1.keybinds[i[0]] = i[1]
		
		else: Settings.controls_p2.keybinds[changing] = ev[2]
	
	get_child(1).visible = false
	waiting = false
	
	rename_button(ev)

func rename_button(ev: Array):
	if ev[0] == "key":
		var event = InputEventKey.new()
		event.keycode = ev[2]
		button_to_change.text = event.as_text().to_upper()
	elif ev[0] == "button":
		if xbox_buttons.size() > ev[2]: button_to_change.text = xbox_buttons[ev[2]][0]
		else: button_to_change.text = str("BUTTON ", ev[2]).to_upper()


func stick(ev) -> Array:
	var ans: Array = []
	var stik: int = 0
	var txt: String = "LEFT STICK "
	if ev[2] > 1:
		stik = 2
		txt = "RIGHT STICK "
	if ev[2] > 3: return []
	if changing.begins_with("MOVE"):
		for n in ["MOVE LEFT","MOVE RIGHT"]:
			ans.append([n, [stik]])
		for n in ["MOVE UP","MOVE DOWN"]:
			ans.append([n, [stik + 1]])
		
		if player == 1: 
			$"VBoxContainer/keys/Move Left/p1".text = str(txt, "LEFT")
			$"VBoxContainer/keys/Move Right/p1".text = str(txt, "RIGHT")
			$"VBoxContainer/keys/Move Up/p1".text = str(txt, "UP")
			$"VBoxContainer/keys/Move Down/p1".text = str(txt, "DOWN")
		if player == 2: 
			$"VBoxContainer/keys/Move Left/p2".text = str(txt, "LEFT")
			$"VBoxContainer/keys/Move Right/p2".text = str(txt, "RIGHT")
			$"VBoxContainer/keys/Move Up/p2".text = str(txt, "UP")
			$"VBoxContainer/keys/Move Down/p2".text = str(txt, "DOWN")
		
	elif changing.begins_with("LOOK"):
		for n in ["LOOK LEFT","LOOK RIGHT"]:
			ans.append([n, [stik]])
		for n in ["LOOK UP","LOOK DOWN"]:
			ans.append([n, [stik + 1]])
		
		if player == 1: 
			$"VBoxContainer/keys/Look Left/p1".text = str(txt, "LEFT")
			$"VBoxContainer/keys/Look Right/p1".text = str(txt, "RIGHT")
			$"VBoxContainer/keys/Look Up/p1".text = str(txt, "UP")
			$"VBoxContainer/keys/Look Down/p1".text = str(txt, "DOWN")
		if player == 2: 
			$"VBoxContainer/keys/Look Left/p2".text = str(txt, "LEFT")
			$"VBoxContainer/keys/Look Right/p2".text = str(txt, "RIGHT")
			$"VBoxContainer/keys/Look Up/p2".text = str(txt, "UP")
			$"VBoxContainer/keys/Look Down/p2".text = str(txt, "DOWN")
	else:
		for n in ["UP","DOWN"]:
			ans.append([n, [stik + 1]])
		for n in ["LEFT","RIGHT"]:
			ans.append([n, [stik]])
		
		if player == 1: 
			$"VBoxContainer/keys/Left/p1".text = str(txt, "LEFT")
			$"VBoxContainer/keys/Right/p1".text = str(txt, "RIGHT")
			$"VBoxContainer/keys/Up/p1".text = str(txt, "UP")
			$"VBoxContainer/keys/Down/p1".text = str(txt, "DOWN")
		if player == 2: 
			$"VBoxContainer/keys/Left/p2".text = str(txt, "LEFT")
			$"VBoxContainer/keys/Right/p2".text = str(txt, "RIGHT")
			$"VBoxContainer/keys/Up/p2".text = str(txt, "UP")
			$"VBoxContainer/keys/Down/p2".text = str(txt, "DOWN")
	
	return ans

func _on_accept_pressed():
	p1_hold = null
	p2_hold = null
	visible = false
	get_parent().find_child("Option").visible = true
	get_parent().find_child("Option").get_child(0).grab_focus()
	p1_controls_node.refresh_controls(0)
	ResourceSaver.save(Settings.controls_p1, "user://control_scheme_1.tres")
	if p2_controls_node:
		p2_controls_node.refresh_controls(1)
		ResourceSaver.save(Settings.controls_p2, "user://control_scheme_2.tres")

func _on_cancel_pressed():
	if p1_hold:
		Settings.controls_p1 = p1_hold
		Settings.controls_p2 = p2_hold
		p1_hold = null
		p2_hold = null
	visible = false
	get_parent().find_child("Option").visible = true
	get_parent().find_child("Option").get_child(0).grab_focus()
	p1_controls_node.refresh_controls(0)
	if p2_controls_node: p2_controls_node.refresh_controls(1)
	for n in buttons_held:
		n[0].text = n[1]

func _on_reset_pressed():
	Settings.controls_p1 = ControlScheme.new()
	Settings.controls_p1.keybinds = ControlScheme.DEFAULT_K.duplicate()
	Settings.controls_p2 = ControlScheme.new()
	Settings.controls_p2.keybinds = ControlScheme.DEFAULT_BLANK.duplicate()
	p1_controls_node.refresh_controls(0)
	if p2_controls_node: p2_controls_node.refresh_controls(1)
	for b:int in get_child(0).get_child(3).get_children().size():
		get_child(0).get_child(3).get_child(b).get_child(0).text = p1_defaults[b]
		get_child(0).get_child(3).get_child(b).get_child(2).text = blank_defaults[b]

func _on_p1_device_pressed():
	remap_button("device", 1)
func _on_p_2_pressed():
	remap_button("device", 2)
