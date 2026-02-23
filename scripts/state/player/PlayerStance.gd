extends State
class_name PlayerStance

# Make these static so the data survives when you swap between Stand/Crouch/Prone nodes
static var holding := false
static var held_time := 0.0
static var start_stance := ""

var transition_time := 0.3

func update(delta: float) -> void:
	# 1. Start the sequence
	if Input.is_action_just_pressed("state_toggle"):
		holding = true
		held_time = 0.0
		start_stance = current_state_name()
		
		# Immediate move toward crouch from extremes
		if start_stance == "Stand" or start_stance == "Prone":
			transitioned.emit(self, "Crouch")
	
	# 2. Handle the hold
	# Checking is_action_pressed ensures we don't desync from the physical keyboard
	if holding and Input.is_action_pressed("state_toggle"):
		held_time += delta
		
		if held_time >= transition_time:
			holding = false
			var now = current_state_name()
			
			# Continue chain based on where we STARTED
			if start_stance == "Stand" and now == "Crouch":
				transitioned.emit(self, "Prone")
			elif start_stance == "Prone" and now == "Crouch":
				transitioned.emit(self, "Stand")
			elif start_stance == "Crouch":
				transitioned.emit(self, "Prone")
	
	# 3. Handle a quick release (tap)
	if Input.is_action_just_released("state_toggle") and holding:
		holding = false
		
		# ONLY stand up on a quick tap if we actually started the whole chain in Crouch.
		if start_stance == "Crouch":
			transitioned.emit(self, "Stand")

# AUX #
func current_state_name() -> String:
	if not current_state: return "" # Safeguard during transitions
	var state_name = current_state.get_script().get_global_name()
	return state_name.substr(6, state_name.length())
