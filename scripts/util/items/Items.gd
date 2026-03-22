extends Node

var EMPTY : Item = Item.new()
#const L_AMMO : Item = preload("res://Resources/Items/Materials/stick.tres")
#const M_AMMO : Item = preload("res://Resources/Items/Materials/rock.tres")
#const H_AMMO : Item = preload("res://Resources/Items/Materials/rock.tres")
#const S_AMMO : Item = preload("res://Resources/Items/Materials/rock.tres")

var all_items = [
	EMPTY
	#L_AMMO,
	#M_AMMO,
	#H_AMMO,
	#S_AMMO
]

var item_registry := {}


func _ready() -> void:
	_register_items()
	EMPTY.item_name = "EMPTY"


func _register_items() -> void:
	for item in all_items:
		item_registry[item.item_name] = item


func get_item(item_name: String) -> Item:
	return item_registry.get(item_name)
