class_name PlayerHurtbox extends Area3D

signal took_damage

func damage() -> void:
	took_damage.emit()
