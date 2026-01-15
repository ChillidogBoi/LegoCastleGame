extends Control

@onready var animation_player = $"../../mesh/Knight1/AnimationPlayer"

func _ready():
	find_child("Main").get_child(0).grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("esc") and not find_child("Keybind").visible:
		if visible: _on_resume_pressed()
		else: _on_pause_pressed()
	
	if $Keybind.p1_controls_node.input_to_bin(Settings.controls_p1.keybinds["START/PAUSE"]) and \
		not find_child("Keybind").visible and not visible: _on_pause_pressed()

func _on_pause_pressed():
	find_child("Main").get_child(0).grab_focus()
	visible = true
	Settings.pause = true
	animation_player.pause()


func _on_resume_pressed():
	visible = false
	Settings.pause = false
	animation_player.play()


func _on_options_pressed():
	find_child("Main").visible = false
	find_child("Option").visible = true
	find_child("Option").get_child(0).grab_focus()

func _on_opt_back_pressed():
	find_child("Main").visible = true
	find_child("Option").visible = false
	find_child("Main").get_child(0).grab_focus()


func _on_keybinds_pressed():
	find_child("Option").visible = false
	find_child("Keybind").visible = true
	$Keybind/VBoxContainer/Accept.grab_focus()
	print(find_child("Keybind").get_child(0).get_child(3).get_child(0).get_child(0))
