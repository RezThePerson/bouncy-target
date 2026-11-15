extends CharacterBody2D

const SPEED := 900.0

func _ready():
	velocity = Vector2.from_angle(randf() * TAU) * SPEED

func _physics_process(delta):
	var hit := move_and_collide(velocity * delta)
	if hit:
		velocity = velocity.bounce(hit.get_normal()).normalized() * SPEED
