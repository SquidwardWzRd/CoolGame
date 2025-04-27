extends Resource
class_name Stats

@export var Strength: int
@export var Vitality: int
@export var Brains: int
@export var Agility: int
@export var Rizz: int


func _init(p_strenght: int = 0, p_vitality: int = 0, p_brains: int = 0, p_agility: int = 0, p_rizz: int = 0) -> void:
	Strength = p_strenght
	Vitality = p_vitality
	Brains = p_brains
	Agility = p_agility
	Rizz = p_rizz

func _get_property_list() -> Array[Dictionary]:
	return [{"Strenght":Strength, "Vitality":Vitality, "Brains":Brains, "Agility":Agility, "Rizz":Rizz}]
