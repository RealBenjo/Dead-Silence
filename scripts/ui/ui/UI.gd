extends CanvasLayer


@onready var select_primary: Control = $SelectPrimary
@onready var hud: Label = $Label

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("tool_select"):
		select_primary.open(Globals.is_using_mouse)
		Engine.time_scale = 0.0
	elif Input.is_action_just_released("tool_select"):
		var tool: String = select_primary.close()
		hud.text = "Player equipped tool: " + tool
		Engine.time_scale = 1.0
