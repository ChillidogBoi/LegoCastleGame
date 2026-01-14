extends State

@export var animation: String

func evaluate(input: InputList) -> String:
	if not chara.is_on_floor():
		return "Fall"
	if input.actions.has("JUMP"):
		return "Jump"
	if input.direction != Vector2.ZERO:
		return "Walk"
	return "okay"

func enter_function():
	anims.play(animation)
	chara.velocity = Vector3.ZERO
