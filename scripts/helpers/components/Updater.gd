extends Node
class_name Updater


signal update(delta: float)
signal fixed_update(delta: float)

func _process(delta: float) -> void:
	update.emit(delta)

func _physics_process(delta: float) -> void:
	fixed_update.emit(delta)
