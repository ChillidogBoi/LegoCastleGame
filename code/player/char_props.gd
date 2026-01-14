extends CharacterBody3D

@export var cam_point:Node3D


func _physics_process(delta):
	cam_point.position.z = lerp(cam_point.position.z, -velocity.length()*0.5, delta*3.0)
	
