extends Node2D

@export var max_health: int = 100
var current_health: int = max_health

signal death

func damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		death.emit()
	return

func heal(amount: int) -> void:
	current_health += amount
	if current_health >= max_health:
		current_health = max_health
	return

func set_max_health(value: int) -> void:
	max_health = value
	return
