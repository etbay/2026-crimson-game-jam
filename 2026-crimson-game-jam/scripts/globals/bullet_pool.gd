class_name BulletPool extends Node3D

static var instance : BulletPool = null
var bullets : Array[Bullet]

func _ready() -> void:
	if (instance == null):
		instance = self
	else:
		queue_free()
	for i in range(0, 100):
		var bullet : Bullet = Bullet.new()
		bullets.append(bullet)
		add_child(bullet)

func get_bullet() -> Bullet:
	if (bullets.is_empty()):
		var bullet : Bullet = Bullet.new()
		add_child(bullet)
		bullet.activate()
		return bullet
	else:
		var bullet = bullets.pop_front()
		bullet.activate()
		return bullet

func return_bullet(b : Bullet) -> void:
	bullets.append(b)
