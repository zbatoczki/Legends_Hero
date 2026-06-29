extends RayCast2D

var _object_to_inteact: Interactable


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"): return
	
	_object_to_inteact = get_collider()
	if not _object_to_inteact == null:
		_object_to_inteact.interact(get_parent())
