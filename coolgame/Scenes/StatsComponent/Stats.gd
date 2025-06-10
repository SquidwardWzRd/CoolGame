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


func _set(property: StringName, value: Variant) -> bool:
	if not property:
		return false
	if property.to_lower() == "strength" and value is int:
		Strength = value
	if property.to_lower() == "vitality" and value is int:
		Vitality = value
	if property.to_lower() == "brains" and value is int:
		Brains = value
	if property.to_lower() == "agility" and value is int:
		Agility = value
	if property.to_lower() == "rizz" and value is int:
		Rizz = value
	return true

func _get(property: StringName) -> Variant:
	if property.to_lower() == "strength":
		return Strength
	if property.to_lower() == "vitality":
		return Vitality
	if property.to_lower() == "brains":
		return Brains
	if property.to_lower() == "agility":
		return Agility
	if property.to_lower() == "rizz":
		return Rizz
	return false
