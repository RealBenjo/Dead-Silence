extends Node
class_name HealthComponent


##the maximum health that the component cannot exceed
@export var MAX_HEALTH := 10.0

signal dead ##fires when health reaches 0
var health: float

func _ready() -> void:
	health = MAX_HEALTH

func damage(attack: Attack) -> void:
	health -= attack.attack_damage
	
	if health <= 0:
		dead.emit()
