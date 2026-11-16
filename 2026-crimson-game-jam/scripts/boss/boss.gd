class_name Boss extends Node3D

@export var attacks: Array[BulletAttack]

var _attacking: bool = false
@export var _attack_delay: float = 6
var _current_attack: BulletAttack = null
var _prev_attack: BulletAttack = null
var _timer: float = 1000
var executer: BulletAttackExecution = null
@export var center: Vector3

var started := true

func _process(delta: float) -> void:
	if (!started):
		return
		
	if(!_attacking):
		_timer += delta
	elif (_current_attack != null):
		executer.increment_patterns(delta, Vector2(global_position.x + center.x, global_position.z + center.z))
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
		executer.execute_patterns(Vector2(global_position.x + center.x, global_position.z + center.z))
