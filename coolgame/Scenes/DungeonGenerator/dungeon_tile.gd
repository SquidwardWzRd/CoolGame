extends Node2D

@onready var atlas: AtlasTexture = load("res://Scenes/DungeonGenerator/sewer_atlas.tres")
var mode: int = 4

@onready var a_rect: Rect2 = atlas.region

@onready var sprite: Sprite2D = $Sprite2D
@onready var ray: RayCast2D = $RayCast2D
var ray_length: float = 16.0

enum {WALL, LADDER, DOOR, FLOOR, BG}

func _ready() -> void:
	pass

func set_ray_direction(direction: Vector2) -> void:
	ray.target_position = direction * ray_length
	return

# Automatically Detect and Assign correct mode
func auto_detect() -> void:
	var dir: Dictionary = check_directions()
	for i in dir.values():
		if i == false:
			set_mode(WALL)
			return
	set_mode(FLOOR)
	return

func set_mode(p_mode: int) -> bool:
	if p_mode > 4 or p_mode < 0:
		return false
	mode = p_mode
	a_rect.position.x = mode * 16
	atlas.region = a_rect
	sprite.texture = atlas
	return true

func check_directions() -> Dictionary:
	var surroundings: Dictionary = {"Right":false, "Left":false, "Up":false, "Down":false}
	# Ray starts out pointing right
	set_ray_direction(Vector2.RIGHT) 
	ray.force_raycast_update()
	if ray.is_colliding():
		surroundings["Right"] = true
	set_ray_direction(Vector2.LEFT) 
	ray.force_raycast_update()
	if ray.is_colliding():
		surroundings["Left"] = true
	set_ray_direction(Vector2.UP) 
	ray.force_raycast_update()
	if ray.is_colliding():
		surroundings["Up"] = true
	set_ray_direction(Vector2.DOWN) 
	ray.force_raycast_update()
	if ray.is_colliding():
		surroundings["Down"] = true
	
	return surroundings
