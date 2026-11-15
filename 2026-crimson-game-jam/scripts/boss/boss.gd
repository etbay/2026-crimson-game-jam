class_name Boss extends Node3D

@export var attacks: Array[BulletAttack]

var _attacking: bool = false
var _attack_delay: float = 2
var _current_attack: BulletAttack = null
var _prev_attack: BulletAttack = null
var _timer: float = 0;
var executer: BulletAttackExecution = null

func _process(delta: float) -> void:
	if(!_attacking):
		_timer += delta
	elif (_current_attack != null):
		executer.increment_patterns(delta, Vector2(position.x, position.z))
		if (executer.finished):
			executer.reset()
			_attacking = false
			_prev_attack = _current_attack
			_current_attack = null
	
	if (_timer > _attack_delay):
		attacks.shuffle()
		if (_prev_attack != null):
			attacks.append(_prev_attack)
		_timer = 0
		_attacking = true
		_current_attack = attacks.pop_front()
		executer = BulletAttackExecution.new(_current_attack)
		executer.execute_patterns(Vector2(position.x, position.z))
