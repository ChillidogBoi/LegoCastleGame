extends Control

@onready var animation_player = $"../../mesh/Knight1/AnimationPlayer"


func _process(delta):
	if Input.is_action_just_pressed("esc"):
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

func _on_opt_back_pressed():
	find_child("Main").visible = true
	find_child("Option").visible = false


func _on_keybinds_pressed():
	find_child("Option").visible = false
	find_child("Keybind").visible = true
