extends ColorRect


func _process(delta):
	for b in get_child(0).get_child(2).get_children():
		if b.get_child(0).button_pressed:
			

func remap_button(b: String, player: int):
	
