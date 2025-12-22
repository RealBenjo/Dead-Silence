extends Node2D
class_name LevelParent


# scene vars
@onready var player: CharacterBody2D = $Player
@onready var zombie_scene: PackedScene = preload("res://scenes/enemies/zombie.tscn")
@onready var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")
@onready var sound_scene: PackedScene = preload("res://scenes/sound/sound.tscn")
@onready var grenade_scene: PackedScene # TODO: actually implement this
@onready var item_scene: PackedScene # TODO: actually implement this

# patrol vars
@onready var patrols = get_node("/root/Level/Patrols").get_children() ##array of ALL patrol nodes
@onready var enemies = get_node("/root/Level/Enemies").get_children() ##array of ALL enemy nodes

var zombie
var bullet
var sound

func _ready() -> void:
	for i in range(patrols.size()):
		var patrol_whole = get_patrol(i)
		
		# at least 2 patrol points need to be avalaible for a zombie
		while patrol_whole.size() >= 2:
			var patrol_zombie: Array = []
			
			# gives zombie 2 patrol points, no 2 zombies have the same patrol points
			for j in range(2):
				var rand = randi() % patrol_whole.size()
				patrol_zombie.append(patrol_whole.get(rand))
				patrol_whole.remove_at(rand)
			
			spawn_enemy(i, patrol_zombie.get(0), patrol_zombie)
			zombie.connect("state_change_signal", self, "update_vision_length")



##spawns a zombie in a Patrol node corresponding to the patrol of the zombie.
##if there is an odd number of patrol points, it's all good, the enemies will simply have one more point to choose, without one additional 
##zombie patroling the map
func spawn_enemy(index: int, pos: Vector2, patrol: Array) -> void: #TODO: make more dynamic, spawn ANY enemy with this function
	var enemy_par_node = enemies.get(index)
	zombie = zombie_scene.instantiate()
	zombie.global_position = pos
	zombie.patrol = patrol
	zombie.last_interest_pos = patrol.get(1) #TODO: rmv line when zombies will patrol on their own
	enemy_par_node.add_child(zombie)

##returns array of all marker positions in a patrol
func get_patrol(index: int) -> Array:
	var patrol_positions: Array
	var patrol = patrols.get(index)
	for j in patrol.get_child_count():
		patrol_positions.append(patrol.get_child(j).position)
	
	return patrol_positions

##spawns a bullet at the player's gun position, which then travels away from the gun barrel
func create_bullet(pos: Vector2, direction: Vector2) -> void:
	bullet = bullet_scene.instantiate() as Node2D
	
	bullet.position = pos
	bullet.rotation = direction.angle()
	bullet.direction = direction
	
	$Projectiles.add_child(bullet)

func create_sound(pos: Vector2, loudness: float) -> void:
	sound = sound_scene.instantiate() as Area2D
	
	sound.position = pos
	sound.loudness = loudness
	
	$Sounds.add_child(sound)

# custom signals
func _on_player_bullet_signal(pos: Vector2, direction: Vector2) -> void:
	create_bullet(pos, direction)

func _on_player_sound_signal(pos: Vector2, loudness: float) -> void:
	create_sound(pos, loudness)
