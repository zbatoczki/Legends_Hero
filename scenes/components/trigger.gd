class_name Trigger extends Area2D

@export var targets: Array[Node]

## Any entity in the selected group that can trigger
@export var accept_groups: Array[StringName] = []

## If true, stays active even after everything leaves.
@export var latch: bool = false

signal activated
signal deactivated

var _occupants: Array[Node2D] = []
var _latched := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _can_activate(body: Node) -> bool:
	if accept_groups.is_empty():
		return true
	for g in accept_groups:
		if body.is_in_group(g):
			return true
	return false


func _on_body_entered(body: Node) -> void:
	if not _can_activate(body):
		return
	var was_active := is_active()
	if body not in _occupants:
		_occupants.append(body)
	if not was_active and is_active():
		_activate()


func _on_body_exited(body: Node) -> void:
	_occupants.erase(body)
	if not _occupants.is_empty():
		return
	if latch:
		return
	_deactivate()


func is_active() -> bool:
	_occupants = _occupants.filter(func(b): return is_instance_valid(b))
	return _latched or not _occupants.is_empty()


func _activate() -> void:
	_latched = latch
	activated.emit()
	for t in targets:
		if t.has_method("on_triggered"):
			t.on_triggered()


func _deactivate() -> void:
	deactivated.emit()
	for t in targets:
		if t.has_method("on_released"):
			t.on_released()
