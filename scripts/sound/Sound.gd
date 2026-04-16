extends Area2D


var loudness: int = 10
var sound_listener: Node2D

func _ready() -> void:
	$CollisionShape2D.shape.radius = loudness


# premade signals

# tells the enemy the sound position
func _on_body_entered(body: Node2D) -> void:
	sound_listener = body
	sound_listener.sound_position = position
	sound_listener.sound_heard = true

# just deletes the sound after short delay
func _on_destroy_sound_timeout() -> void:
	if sound_listener != null:
		sound_listener.sound_heard = false
	queue_free()
