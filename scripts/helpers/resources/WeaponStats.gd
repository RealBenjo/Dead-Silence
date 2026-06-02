extends Resource
class_name WeaponStats


@export var texture: Texture

@export_group("Attributes")
@export_range(0.0, 90.0, 0.1, "degrees") var inaccuracy := 10.0
@export_range(0, 5) var firing_cooldown := 0.5
@export var ammo_type: Item
@export var magazine_size := 30
@export var reload_time := 1.0 ## in seconds
@export var loudness := 3000 ## how big the sound the weapon creates (in pixels)

@export_group("Attack")
@export var speed := 3000.0
@export var damage := 5.0
@export var max_pierce := 1
@export var knockback_force := 1.0

@export_group("Visuals")
@export var weapon_sprite_region: Rect2
@export var weapon_sprite_pos := Vector2.ZERO
@export var muzzle_pos := Vector2.ZERO
@export var aim_frame := 0 ## 0 is one handed, 1 is two handed

## just stores the current ammo of a weapon. this means, if the weapon is switched
## the amount of ammo in a magazine should stay the same
var current_ammo := -1

## keeps check if the weapon is being reloaded
var is_reloading := false
var reload_time_left := -1.0

## initializes stats like current_ammo, reload_time_left
func init_stats() -> void:
	if current_ammo == -1.0:
		current_ammo = magazine_size
	
	if reload_time_left == -1:
		reload_time_left = reload_time
