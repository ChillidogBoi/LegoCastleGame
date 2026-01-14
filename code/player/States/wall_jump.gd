extends State


const JUMP_VEL = 5.0
var finished = "okay"
var enter_velo: Vector3

func evaluate(input: InputList) -> String:
	return finished

func enter_function():
	enter_velo = chara.velocity
	anims.play("jump")
	mesh.look_at(mesh.global_position + chara.get_wall_normal())
	chara.velocity = chara.get_wall_normal() * 7.5
	chara.velocity.y += JUMP_VEL
	chara.move_and_slide()
	await anims.animation_finished
	if get_parent().current_state == self:
		finished = "Fall"

func exit_function():
	anims.play_backwards("jump")
	finished = "okay"

func function(input: InputList, delta: float):
	var direction = (Vector3(input.direction.x, 0, input.direction.y).rotated(Vector3.UP, chara.rotation.y)).normalized()
	
	if not chara.is_on_floor():
		chara.velocity += chara.get_gravity() * delta
	chara.move_and_slide()
