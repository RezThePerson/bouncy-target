extends CharacterBody2D

signal hit_target

const BASE_SPEED := 500.0
const SPEED_STEP := 100.0
const MIN_AXIS_COMPONENT := 0.25   # keeps ball from bouncing purely horizontally/vertically
const STUCK_CHECK_TIME := 0.4
const STUCK_DISTANCE := 20.0
const BOUNCE_SOUND := preload("res://assets/ballbounce.wav")

var speed := BASE_SPEED
var _stuck_timer := 0.0
var _stuck_origin := Vector2.ZERO
var _bounce_player: AudioStreamPlayer2D

func _ready():
	safe_margin = 0.5
	_bounce_player = AudioStreamPlayer2D.new()
	_bounce_player.stream = BOUNCE_SOUND
	add_child(_bounce_player)
	velocity = Vector2.from_angle(randf() * TAU) * speed
	_fix_angle()
	_stuck_origin = global_position

func _physics_process(delta: float) -> void:
	var motion: Vector2 = velocity * delta
	for i in 4:  # handle corners / multiple hits in one frame
		var hit: KinematicCollision2D = move_and_collide(motion)
		if hit == null:
			break
		var n: Vector2 = hit.get_normal()
		var collider: Object = hit.get_collider()
		if collider != null and collider.name == "Target":
			speed += SPEED_STEP
			hit_target.emit()
		_bounce_player.play()
		velocity = velocity.bounce(n).normalized() * speed
		_fix_angle()
		motion = hit.get_remainder().bounce(n)
		global_position += n * 0.5  # tiny push out so we don't re-hit instantly

	_check_stuck(delta)

func _fix_angle() -> void:
	var d := velocity.normalized()
	if abs(d.x) < MIN_AXIS_COMPONENT:
		d.x = MIN_AXIS_COMPONENT * (1.0 if randf() > 0.5 else -1.0) if d.x == 0.0 else MIN_AXIS_COMPONENT * sign(d.x)
	if abs(d.y) < MIN_AXIS_COMPONENT:
		d.y = MIN_AXIS_COMPONENT * (1.0 if randf() > 0.5 else -1.0) if d.y == 0.0 else MIN_AXIS_COMPONENT * sign(d.y)
	velocity = d.normalized() * speed

func _check_stuck(delta: float) -> void:
	_stuck_timer += delta
	if _stuck_timer < STUCK_CHECK_TIME:
		return
	if global_position.distance_to(_stuck_origin) < STUCK_DISTANCE:
		# stuck: kick it in a fresh random direction and shove it free
		var dir := Vector2.from_angle(randf() * TAU)
		global_position += dir * 6.0
		velocity = dir * speed
		_fix_angle()
	_stuck_timer = 0.0
	_stuck_origin = global_position
