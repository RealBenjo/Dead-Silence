extends Area2D
class_name AttackComponent


signal attacked(body)

func _on_body_entered(body: Node2D) -> void:
	attacked.emit(body)
