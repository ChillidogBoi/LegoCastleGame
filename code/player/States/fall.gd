extends State

@export var animation: String
const AIR_CONTROL = 6.0
var jump_after = false
var enter_velo: Vector3
var time_passed: float = 0

func function(input: InputList, delta: float):
	var direction = (Vector3(input.direction.x, 0, input.direction.y).rotated(Vector3.UP, chara.rotation.y)).normalized()
	chara.velocity.x = direction.x * AIR_CONTROL
	chara.velocity.z = direction.z * AIR_CONTROL
	if direction:
		mesh.look_at(mesh.global_position + direction)
	
	chara.velocity += chara.get_gravity() * delta * 2.25
	chara.move_and_slide()
	
	time_passed += delta
	if time_passed > 0.1875: anims.play(animation)

func enter_function():
	enter_velo = chara.velocity

func evaluate(input: InputList) -> String:
	if jump_after and chara.is_on_floor():
		get_parent().rolled = false
		return "Jump"
	if input.actions.has("JUMP") and not get_parent().rolled:
		return "Roll"
	if not chara.is_on_floor():
		return "okay"
	if input.direction != Vector2.ZERO:
		get_parent().rolled = false
		return "Walk"
	else:
		get_parent().rolled = false
		return "Idle"

func exit_function():
	jump_after = false
	time_passed = 0
