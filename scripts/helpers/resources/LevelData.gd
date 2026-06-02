extends Resource
class_name LevelData


## name of the level (this is used in the mission selection menu)
@export var name: String
## description of the level (this is used in the mission selection menu)
@export_multiline var description: String = "Write a nice description here :)"
## local path to the level scene (ctrl + shift + c to copy the scene path from
## the file browser)
@export var path: String
