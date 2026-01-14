extends Node


var pause = true

var controls_p1: ControlScheme
var controls_p2: ControlScheme

var controls_setup = false
signal initialized

func _ready():
	if FileAccess.file_exists("user://control_scheme_1.res"):
		controls_p1 = ResourceLoader.load("user://control_scheme_1.res")
		if controls_p1.device is int:
			if not Input.get_connected_joypads().has(controls_p1.device):
				controls_p1.keybinds = ControlScheme.DEFAULT_K.duplicate()
		controls_setup = true
	else: controls_p1 = ControlScheme.new()
	if FileAccess.file_exists("user://control_scheme_2.res"):
		controls_p2 = ResourceLoader.load("user://control_scheme_2.res")
		if controls_p2.device is int:
			if not Input.get_connected_joypads().has(controls_p2.device):
				controls_p2.keybinds = ControlScheme.DEFAULT_K2.duplicate()
	
	initialized.emit()
	
	
func _input(event):
	if not controls_setup:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			controls_p1.keybinds = ControlScheme.DEFAULT_J.duplicate()
		else:
			controls_p1.keybinds = ControlScheme.DEFAULT_K.duplicate()
		controls_setup = true
		
		initialized.emit()
