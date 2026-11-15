class_name BulletAttackExecution extends Node

var attack_data: BulletAttack = null
var _timer: float = 0
var finished: bool = false
var _pattern_executers: Array[BulletExecution]

func _init(attack: BulletAttack) -> void:
	attack_data = attack

func execute_patterns(center: Vector2) -> void:
	var i: int = 0
	for p in attack_data.patterns:
		var executer: BulletExecution = BulletExecution.new(p.duplicate(), center + attack_data.pattern_positions[i])
		_pattern_executers.append(executer)
		executer.execute()
		i += 1

func increment_patterns(delta: float, center: Vector2):
	_timer += delta
	finished = true
	var i: int = 0
	for e in _pattern_executers:
		e.increment_pattern(delta, attack_data.pattern_positions[i])
		if not e._finished:
			finished = false
		i += 1

func reset() -> void:
	_timer = 0
	finished = false
	attack_data = null
	_pattern_executers.clear()
