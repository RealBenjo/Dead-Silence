extends Node
class_name State

signal transitioned(self_state, state_node_name)

var current_state: State
var state_name: String

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass
