extends Node

@export var current_state: State
@export var controls: InputController
@export var chara: CharacterBody3D
@export var anims: AnimationPlayer
@export var mesh: Node3D
@export var sensors: Node3D

var input: InputList
var rolled: bool = false

func _ready():
	for n: State in get_children():
		n.chara = chara
		n.anims = anims
		n.mesh = mesh
		n.sensors = sensors
	if current_state.is_inside_tree():
		current_state.enter_function()

func _physics_process(delta):
	if Settings.pause: return
	
	if input: input = controls.get_input(input)
	else: input = controls.get_input(InputList.new())
	var ans = current_state.evaluate(input)
	if ans != "okay":
		change_state_to(ans)
		return
	current_state.function(input, delta)
	$"../UI/menu/Debug/Label".text = str("  Speed: ", chara.velocity)
	$"../UI/menu/Debug/Label2".text = str("  State: ", current_state.name)
	$"../UI/menu/Debug/Label3".text = str(input.actions)

func change_state_to(to: String):
	var new_state: State = find_child(to)
	current_state.exit_function()
	current_state = new_state
	current_state.enter_function()
