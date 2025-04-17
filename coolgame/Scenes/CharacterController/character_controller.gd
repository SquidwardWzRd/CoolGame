extends Area2D

@export var tile_size = 16
@export var animation_speed = 5
var moving = false

# Map Input
var inputs = {"right": Vector2.RIGHT,
		"left": Vector2.LEFT,
		"up": Vector2.UP,
		"down": Vector2.DOWN}


func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

func _unhandled_input(event):
	if moving:
		return
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	#position += inputs[dir] * tile_size
	var tween = create_tween()
	tween.tween_property(self, "position", position + inputs[dir] *    tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
