extends Resource
class_name WeaponStats


@export var texture: Texture

@export_group("Attributes")
@export_range(0.0, 90.0, 1.0, "degrees") var inaccuracy := 10.0
@export_range(0, 5) var firing_cooldown := 0.5
@export var ammo_type: Item

@export_group("Attack")
@export var speed := 3000.0
@export var damage := 5.0
@export var max_pierce := 1
@export var knockback_force := 1.0
