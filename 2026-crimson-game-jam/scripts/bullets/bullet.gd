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

var _active : bool = false

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
	self.visible = false
	_active = false

func _init(_size : float = 1, _angle : float = 0, _speed : float = 0, _accel : float = 0, _turn_rate : float = 0, _turn_rate_accel : float = 0, _lifetime : float = -1, _parryable : bool = false) -> void:
	define_bullet(_size, _angle, _speed, _accel, _turn_rate, _turn_rate_accel, _lifetime, _parryable)

func define_bullet(_size : float = 1, _angle : float = 0, _speed : float = 0, _accel : float = 0, _turn_rate : float = 0, _turn_rate_accel : float = 0, _lifetime : float = -1, _parryable : bool = false) -> void:
	angle = _angle
	speed = _speed
	acceleration = _accel
	turn_rate = _turn_rate
	turn_rate_accel = _turn_rate_accel
	lifetime = _lifetime
	age = 0
	parryable = _parryable
	size = _size
	_active = true

func define_bullet_from_data(data : BulletData):
	speed = data.bullet_speed
	acceleration = data.bullet_accel
	turn_rate = data.bullet_turn_rate_deg
	turn_rate_accel = data.bullet_turn_rate_accel
	lifetime = data.bullet_lifetime
	age = 0
	parryable = false
	size = data.bullet_size
	_active = true
	update_sprite()

func update_sprite():
	if (parryable):
		sprite.texture = TextureLibrary.BULLET_PARRYABLE
	else:
		sprite.texture = TextureLibrary.BULLET_SPRITE
	sprite.scale = Vector3(size, size, 1)
	shape.shape.radius = size / 2

func _process(delta : float) -> void:
	if (_active):
		## update pos, and motion params
		age += delta
		if (lifetime > 0 and age >= lifetime):
			kill_bullet()
		speed += acceleration * delta
		turn_rate += turn_rate_accel * delta
		angle += turn_rate * delta
		update_position(delta)

func update_position(delta : float) -> void:
	var direction : Vector2 = Vector2.from_angle(angle) * speed * delta
	self.position += Vector3(direction.x, 0, direction.y)	

func _on_area_entered(area : Area3D) -> void:
	if (_active):
		pass

func activate() -> void:
	visible = true
	_active = true

func kill_bullet() -> void:
	define_bullet()
	self.visible = false
	_active = false
	BulletPool.instance.return_bullet(self) # replace with object pooling
