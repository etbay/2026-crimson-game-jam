class_name Bullet extends Area3D
# Class references
var shape : CollisionShape3D
var sprite : Sprite3D
var size : float

# Parameters for actions
# scalars
var angle : float
var speed : float
# over time changes
var acceleration : float
var turn_rate : float
var turn_rate_accel : float
var lifetime : float # fade away or -1 for infinite
var age : float
var parryable : bool

#var homing : bool

func _ready() -> void:
	sprite = Sprite3D.new()
	sprite.texture = TextureLibrary.BULLET_SPRITE
	add_child(sprite)
	area_entered.connect(_on_area_entered)
	sprite.rotation = Vector3(90, 0, 0)
	
	shape = CollisionShape3D.new()
	shape.shape = CylinderShape3D.new()
	add_child(shape)
	update_sprite()

func _init(_size : float = .4, _angle : float = 0, _speed : float = 5, _accel : float = 0, _turn_rate : float = 2, _turn_rate_accel : float = 0, _lifetime : float = -1, _parryable : bool = false) -> void:
	define_bullet(_size, _angle, _speed, _accel, _turn_rate, _turn_rate_accel, _lifetime, _parryable)

func define_bullet(_size : float, _angle : float, _speed : float, _accel : float, _turn_rate : float, _turn_rate_accel : float, _lifetime : float, _parryable : bool = false) -> void:
	angle = _angle
	speed = _speed
	acceleration = _accel
	turn_rate = _turn_rate
	turn_rate_accel = _turn_rate_accel
	lifetime = _lifetime
	age = 0
	parryable = _parryable
	size = _size

func update_sprite():
	if (parryable):
		sprite.texture = TextureLibrary.BULLET_PARRYABLE
	else:
		sprite.texture = TextureLibrary.BULLET_SPRITE
	sprite.scale = Vector3(size, size, 1)
	shape.shape.radius = size / 2

func _process(_delta : float) -> void:
	## update pos, and motion params
	age += _delta
	if (lifetime > 0 and age >= lifetime):
		kill_bullet()
	speed += acceleration * _delta
	turn_rate += turn_rate_accel * _delta
	angle += turn_rate * _delta
	
	update_position(_delta)
	
	pass

func update_position(_delta : float) -> void:
	var direction : Vector2 = Vector2.from_angle(angle) * speed * _delta
	self.position += Vector3(direction.x, 0, direction.y)	

func _on_area_entered() -> void:
	
	pass

func kill_bullet():
	queue_free() # replace with object pooling
