extends Node2D

@export var mst: Array
@export var mainrooms: Array

@export var line_width: float = 4.0

func _draw() -> void:
	for edge in mst:
		draw_line(mainrooms[edge["from"]][0], mainrooms[edge["to"]][0], Color.GREEN, line_width)
