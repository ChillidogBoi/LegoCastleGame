extends State

@export var animation: String

const AIR_CONTROL = 6.0
const JUMP_VEL = 0.25
var finished = "okay"
var enter_velo: Vector3
var time_passed: float = 0

func evaluate(input: InputList) -> String:
	if chara.is_on_floor() and input.actions.has("JUMP") and time_passed > 0.55: return "Jump"
	else: return finished

func enter_function():
	enter_velo = chara.velocity
	anims.play(animation)
	chara.velocity.y += 0
	await anims.animation_finished
	if get_parent().current_state == self:
		finished = "Fall"

func exit_function():
	get_parent().rolled = true
	finished = "okay"
	time_passed = 0

func function(input: InputList, delta: float):
	var direction = (Vector3(input.direction.x, 0, input.direction.y).rotated(Vector3.UP, chara.rotation.y)).normalized()
	chara.velocity.x = direction.x * AIR_CONTROL + enter_velo.x * JUMP_VEL
	chara.velocity.z = direction.z * AIR_CONTROL + enter_velo.z * JUMP_VEL
	if direction:
		mesh.look_at(mesh.global_position + direction)
	
	if not chara.is_on_floor():
		chara.velocity += chara.get_gravity() * delta * 2.0
	chara.move_and_slide()
	
	time_passed += delta
