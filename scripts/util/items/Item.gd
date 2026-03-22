extends Resource
class_name Item


@export var item_name := ""
@export var sprite := AtlasTexture.new()


func _to_string() -> String:
	return item_name
