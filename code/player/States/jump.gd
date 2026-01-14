extends State

@export var animation: String
const AIR_CONTROL = 6.0
const JUMP_VEL = 7.5
var finished = "okay"
var enter_velo: Vector3
var time_passed: float = 0

func evaluate(input: InputList) -> String:
	if input.actions.has("JUMP"): finished = "Roll"
	return finished

func enter_function():
	enter_velo = chara.velocity
	anims.play(animation)
	chara.velocity.y += JUMP_VEL
	await anims.animation_finished
	if get_parent().current_state == self:
		finished = "Fall"

func exit_function():
	anims.play_backwards(animation)
	finished = "okay"
	time_passed = 0

func function(input: InputList, delta: float):
	var direction = (Vector3(input.direction.x, 0, input.direction.y).rotated(Vector3.UP, chara.rotation.y)).normalized()
	chara.velocity.x = direction.x * AIR_CONTROL
	chara.velocity.z = direction.z * AIR_CONTROL
	if direction:
		mesh.look_at(mesh.global_position + direction)
	
	if not chara.is_on_floor():
		chara.velocity += chara.get_gravity() * delta * 1.75
	chara.move_and_slide()
	
	time_passed += delta
