extends Node
class_name SoundEmitter

@onready var sound_scene: PackedScene = preload("res://scenes/sound/sound.tscn");
var sound

func create_sound(pos: Vector2, loudness: float) -> void:
	sound = sound_scene.instantiate() as Area2D
	
	sound.position = pos
	sound.loudness = loudness
	
	Globals.world_2d.get_child(0).add_child(sound)
