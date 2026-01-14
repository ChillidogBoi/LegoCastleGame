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
