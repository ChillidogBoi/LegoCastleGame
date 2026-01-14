extends ColorRect

var waiting: bool = false
var player: int = 1
var changing: String

var p1_hold: ControlScheme
var p2_hold: ControlScheme

func _process(delta):
	for b in get_child(0).get_child(2).get_children():
		if b.get_child(0).button_pressed:
			remap_button(b.get_child(1).text, 1)
		elif b.get_child(2).button_pressed:
			remap_button(b.get_child(1).text, 2)

func remap_button(b: String, p: int):
	if not p1_hold:
		p1_hold = Settings.controls_p1
		p2_hold = Settings.controls_p2
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
		ans[1] = false
		ans.append(ev.keycode)
	
	return ans

func _input(event):
	if !waiting or !event.is_pressed() or event is InputEventGesture or event is InputEventMouse: return
	if event is InputEventScreenDrag or event is InputEventMIDI or event is InputEventScreenTouch: return
	
	var ev: Array = parse_input_event(event)
	
	if ev[0] == "stick" and InputController.InputActionsMasks.has(changing): return
	
	if changing == "device":
		if player == 1:
			if Settings.controls_p1.device == ev[1]: return
			Settings.controls_p1 = ControlScheme.new()
			if ev[1]: Settings.controls_p1.keybinds = ControlScheme.DEFAULT_J.duplicate()
			else: Settings.controls_p1.keybinds = ControlScheme.DEFAULT_K.duplicate()
			Settings.controls_p1.device = ev[1]
		elif player == 2:
			if Settings.controls_p2.device == ev[1]: return
			Settings.controls_p2 = ControlScheme.new()
			if ev[1]: Settings.controls_p2.keybinds = ControlScheme.DEFAULT_J.duplicate()
			else: Settings.controls_p2.keybinds = ControlScheme.DEFAULT_K2.duplicate()
			Settings.controls_p2.device = ev[1]
		return
	
	if player == 1:
		if Settings.controls_p1.device != ev[1]: return
			
		if ev[0] == "stick": Settings.controls_p1.keybinds[changing] = [ev[2]]
		else: Settings.controls_p1.keybinds[changing] = ev[2]
		
	elif player == 2:
		if Settings.controls_p2.device != ev[1]: return
			
		if ev[0] == "stick": Settings.controls_p2.keybinds[changing] = [ev[2]]
		else: Settings.controls_p2.keybinds[changing] = ev[2]


func _on_accept_pressed():
	p1_hold = null
	p2_hold = null
	visible = false
	get_parent().find_child("Option").visible = true

func _on_cancel_pressed():
	if not p1_hold: return
	Settings.controls_p1 = p1_hold
	Settings.controls_p2 = p2_hold
	p1_hold = null
	p2_hold = null
	visible = false
	get_parent().find_child("Option").visible = true

func _on_reset_pressed():
	Settings.controls_p1 = ControlScheme.new()
	Settings.controls_p2.keybinds = ControlScheme.DEFAULT_K.duplicate()
	Settings.controls_p2 = ControlScheme.new()
	Settings.controls_p2.keybinds = ControlScheme.DEFAULT_K2.duplicate()

func _on_p1_device_pressed():
	remap_button("device", 1)
func _on_p_2_pressed():
	remap_button("device", 2)
