extends Control


@onready var selection_container: VBoxContainer = %SelectionContainer
@onready var mission_description: Label = %MissionDescription
@onready var start_mission_btn: Button = %StartMission

## this sets the button size of every selection button
## (change y if you want them to be taller/smaller)
@export var button_size := Vector2(0, 50)

var selected_mission_path: String = ""


func _ready() -> void:
	# disable the start mission at first so the player cant start
	# a mission without selecting one
	start_mission_btn.disabled = true
	
	for mission_str: String in Globals.levels:
		# get the actual resource from the Globals dictionary
		var mission: LevelData = Globals.levels[mission_str]
		
		# create the button which will be used to select a mission
		var button := Button.new()
		
		# set all button variables to something we actually want
		button.name = mission_str
		button.text = mission.name # give it the mission name
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT # align it left
		button.custom_minimum_size = button_size # give it some size
		
		# when arrow keys/D-pad highlight this button, update the description instantly!
		button.focus_entered.connect(select_mission.bind(mission))
		
		# when the mouse hovers over it, force it to grab focus. 
		# This automatically fires the 'focus_entered' signal above, keeping mouse and controller behavior identical!
		button.mouse_entered.connect(button.grab_focus)
		
		# lastly actually add the button to the selection container :)
		selection_container.add_child(button)

## this function is called by every mission select button to update
## important data like the mission_description and selected_mission_path
func select_mission(mission: LevelData) -> void:
	# change the mission description
	mission_description.text = mission.description
	
	# update the selected mission path
	selected_mission_path = mission.path
	
	# enable the start mission button now that the mission is selected
	start_mission_btn.disabled = false


func _on_start_mission_pressed() -> void:
	# swap to the selected mission now that it is selected :D
	SceneManager.swap_scenes(selected_mission_path, Globals.world_2d, self, "fade_to_black")
