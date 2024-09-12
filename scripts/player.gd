extends Area2D

signal hit

@export var speed = 200 
var screen_size

var projectile_speed = 600
var projectile_scene = preload("res://scenes/projectile.tscn")

@onready var projectile_container = $ProjectileContainer

var facing_direction = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

func _input(event: InputEvent) -> void:
	# Update player direction based on input (for 4 directions: up, down, left, right)
	if Input.is_action_pressed("move_up"):
		facing_direction = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		facing_direction = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		facing_direction = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		facing_direction = Vector2.RIGHT

	# Fire the projectile
	if event.is_action_pressed("shoot_projectile"):
		shoot_projectile()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	update_animation(velocity, delta)

func update_animation(velocity: Vector2, delta: float) -> void:
	velocity = velocity.normalized() * speed
	$AnimatedSprite2D.play()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0 || velocity.y != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.animation = "idle"

func _physics_process(delta: float) -> void:
	var screen_size = get_viewport_rect().size
	global_position = global_position.clamp(Vector2(0,0), screen_size)

func shoot_projectile() -> void:
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.global_position = global_position
	
	if facing_direction.x > 0:
		projectile_instance.global_position.x += 80
	elif facing_direction.x < 0:
		projectile_instance.global_position.x -= 80
	elif facing_direction.y > 0:
		projectile_instance.global_position.y += 80
	else:
		projectile_instance.global_position.y -= 80
		
	projectile_instance.set_direction(facing_direction)
	projectile_container.add_child(projectile_instance)

	# play projectile sound here

func _on_body_entered(body: Node2D) -> void:
	Global.camera.shake(0.2, 6)
	hide() # Player disappears after being hit
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
