extends State

const SPEED = 7.5
@export var animation: String

func evaluate(input: InputList) -> String:
	if not chara.is_on_floor():
		return "Fall"
	if input.actions.has("JUMP"):
		return "Jump"
	if input.direction == Vector2.ZERO:
		return "Idle"
	return "okay"

func function(input: InputList, delta: float):
	var direction = (Vector3(input.direction.x, 0, input.direction.y).rotated(Vector3.UP, chara.rotation.y)).normalized()
	chara.velocity = direction * SPEED
	mesh.look_at(mesh.global_position + direction)
	if sensors.find_child("stair").is_colliding(): chara.position.y += 0.3
	chara.move_and_slide()

func enter_function():
	if anims.current_animation != animation: anims.play(animation)
