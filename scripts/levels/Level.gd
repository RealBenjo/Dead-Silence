extends Node2D
class_name LevelParent


# scene vars
@onready var player: CharacterBody2D = $Player
@onready var zombie_scene: PackedScene = preload("res://scenes/enemies/zombie.tscn")
@onready var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")
@onready var sound_scene: PackedScene = preload("res://scenes/sound/sound.tscn")
@onready var grenade_scene: PackedScene # TODO: actually implement this BUT NOT HERE
@onready var item_scene: PackedScene # TODO: actually implement this BUT NOT HERE

# patrol vars
@onready var patrols = $Patrols.get_children() ## array of ALL patrol nodes
@onready var enemies = $Enemies.get_children() ## array of ALL enemy nodes

var zombie
var bullet
var sound

func _ready() -> void:
	# 1. Count exactly how many objectives exist when the level starts
	Globals.total_objectives = get_tree().get_nodes_in_group("Objective").size()
	print("Total objectives to rescue: ", Globals.total_objectives)
	
	for i in range(patrols.size()):
		var patrol_whole = get_patrol(i)
		
		# at least 2 patrol points need to be avalaible for a zombie
		while patrol_whole.size() >= 2:
			var patrol_zombie: Array = [] ## the dedicated patrol points for zombies
			
			# gives zombie 2 patrol points, no 2 zombies have the same patrol points
			for j in range(2):
				var rand = randi() % patrol_whole.size()
				patrol_zombie.append(patrol_whole.get(rand))
				patrol_whole.remove_at(rand)
			
			spawn_enemy(i, patrol_zombie.get(0), patrol_zombie)



## spawns a zombie in a Patrol node corresponding to the patrol of the zombie.
## if there is an odd number of patrol points, it's all good, the enemies will simply have one more point to choose, without one additional 
## zombie patroling the map
func spawn_enemy(index: int, pos: Vector2, patrol: Array) -> void: #TODO: make more dynamic, spawn ANY enemy with this function
	var enemy_par_node = enemies.get(index)
	
	zombie = zombie_scene.instantiate()
	zombie.global_position = pos
	zombie.patrol = patrol
	
	enemy_par_node.add_child(zombie)



## returns array of all marker positions in a patrol
func get_patrol(index: int) -> Array:
	var patrol_positions: Array
	var patrol = patrols.get(index)
	for j in patrol.get_child_count():
		patrol_positions.append(patrol.get_child(j).position)
	
	return patrol_positions
