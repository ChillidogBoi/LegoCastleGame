extends State

const AIR_CONTROL = 6.0
var jump_after = false
var enter_velo: Vector3

func function(input: InputList, delta: float):
	var direction = (Vector3(input.direction.x, 0, input.direction.y).rotated(Vector3.UP, chara.rotation.y)).normalized()
	chara.velocity.x = direction.x * AIR_CONTROL + enter_velo.x/2
	chara.velocity.z = direction.z * AIR_CONTROL + enter_velo.z/2
	
	chara.velocity += chara.get_gravity() * delta * 0.5
	chara.move_and_slide()

func enter_function():
	anims.play("fall")
	mesh.look_at(mesh.global_position + chara.get_wall_normal() * -1)

func evaluate(input: InputList) -> String:
	if chara.is_on_wall_only() and input.actions.has("JUMP"):
		return "WallJump"
	if chara.is_on_wall_only():
		return "okay"
	if not chara.is_on_wall() and not chara.is_on_floor():
		return "Fall"
	if input.direction != Vector2.ZERO:
		return "Walk"
	else: return "Idle"

func exit_function():
	jump_after = false
