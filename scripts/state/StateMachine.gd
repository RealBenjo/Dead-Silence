extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}
var last_state_name: String = ""

func _ready() -> void:
	# gets all the states that are it's children
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child # put the state in the dictionary
			child.transitioned.connect(on_child_transition) # simply connect the State's signal
	
	# if initial_state exists, enter it and set the current_state to be initial_state
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)



func on_child_transition(state, new_state_name):
	if state != current_state:
		print("ERROR. the following states are NOT the same:")
		print(state)
		print(current_state)
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("ERROR. the new state does NOT exist:")
		print(new_state)
		return
	
	last_state_name = current_state.name
	current_state.exit()
	new_state.enter()
	
	current_state = new_state
