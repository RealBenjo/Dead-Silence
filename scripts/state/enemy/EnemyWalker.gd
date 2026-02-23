extends State
class_name EnemyWalker

var enemy_interest_pos: Vector2

##if an enemy is more aware than a certain max_awareness percentage, it will enter the appropriate state
func check_awareness(awareness: float, max_awareness: float) -> void:
	if awareness >= max_awareness:
		#TODO: implement slow-mo when getting detected by an enemy
		#Engine.time_scale = 0.1
		transitioned.emit(self, "Attacking")
		
	elif awareness > max_awareness * 0.5:
		# if an enemy sees a player for more than 50% awareness they will know the player's exact position
		enemy_interest_pos = Globals.player_pos
		if current_state is EnemyPatrolling:
			transitioned.emit(self, "Investigating")
