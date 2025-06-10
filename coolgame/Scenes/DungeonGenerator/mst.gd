extends Node2D

@export var mst: Array
@export var mainrooms: Array

@export var line_width: float = 4.0

func _draw() -> void:
	for edge in mst:
		draw_line(mainrooms[edge["from"]].get_center(), mainrooms[edge["to"]].get_center(), Color.GREEN, line_width)
