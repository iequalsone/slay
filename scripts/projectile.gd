extends Area2D

@export var speed: int = 500

@onready var visible_notifier = $VisibleNotifier

var direction = Vector2.ZERO

func _ready() -> void:
	visible_notifier.connect("screen_exited", _on_screen_exited)
	
func set_direction(new_direction):
	direction = new_direction

func _physics_process(delta: float) -> void:
	if direction.x > 0:
		global_position.x += speed * delta
	elif direction.x < 0:
		global_position.x -= speed * delta
	elif direction.y > 0:
		global_position.y += speed * delta
	else:
		global_position.y -= speed * delta

func _on_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	body.die()
	queue_free()
