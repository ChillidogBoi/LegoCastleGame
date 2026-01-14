extends Node3D



@export var player:Node3D
@export var aim_help:Node3D
@onready var camera_3d = $Camera3D

@export var stage_dimentions:Vector2
var look_point: Vector3

func _process(delta):
	global_position = lerp(global_position,player.global_position,delta*8.0)
	global_position.x = clampf(global_position.x,-stage_dimentions.x/2,stage_dimentions.x/2)
	global_position.z = clampf(global_position.z,-stage_dimentions.y/2,stage_dimentions.y/2)
	
	look_point = lerp(look_point, (aim_help.global_position+global_position)/2+Vector3.UP, delta*8.0)
	camera_3d.look_at(look_point,Vector3.UP)
	
	$MeshInstance3D2.global_position = ((aim_help.global_position+global_position)/2)+Vector3.UP
	
