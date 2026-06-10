extends Sprite2D


@onready var zombie: CharacterBody2D = $".."

func _physics_process(_delta: float) -> void:
	global_rotation = 0
	global_position = zombie.global_position - Vector2(0, 100)
