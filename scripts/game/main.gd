extends Node2D

const MIN_DIST := 8.0
const LINE_WIDTH := 5.0
const LINE_COLOR := Color(0.33, 0.079, 0.18, 1.0)
const BALL_CLEARANCE := 24.0

const START_TIME := 30.0
const TIME_PER_LEVEL_REDUCTION := 2.0
const MIN_TIME := 5.0

var wall_body: StaticBody2D
var stroke: Line2D = null
var last_pos := Vector2.ZERO

var level := 1
var time_limit := START_TIME
var time_left := START_TIME

@onready var level_label: Label = $Level/level
@onready var time_label: Label = $Time/time

var ball_start_pos := Vector2.ZERO
var strokes: Array[Line2D] = []

var strokes_root: Node2D

func _ready() -> void:
	print("main.gd ready")
	wall_body = StaticBody2D.new()
	wall_body.name = "PlayerWalls"
	wall_body.collision_layer = 1
	add_child(wall_body)

	strokes_root = Node2D.new()
	strokes_root.name = "Strokes"
	add_child(strokes_root)

	ball_start_pos = $Ball.global_position
	$Ball.hit_target.connect(_on_target_hit)
	_update_ui()

func _on_target_hit() -> void:
	level += 1
	time_limit = max(MIN_TIME, time_limit - TIME_PER_LEVEL_REDUCTION)
	time_left = time_limit
	_clear_strokes()
	_reset_ball()
	_update_ui()

func _clear_strokes() -> void:
	stroke = null
	for s in strokes_root.get_children():
		s.queue_free()
	for cs in wall_body.get_children():
		cs.queue_free()

func _reset_ball() -> void:
	var ball := get_node_or_null("Ball")
	if ball:
		ball.global_position = ball_start_pos
func _process(delta: float) -> void:
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		_update_ui()
		_game_over()
		return
	_update_ui()

func _physics_process(_delta: float) -> void:
	var held := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var p := get_global_mouse_position()

	if not held:
		stroke = null
		return

	if stroke == null:
		stroke = Line2D.new()
		stroke.width = LINE_WIDTH
		stroke.default_color = LINE_COLOR
		stroke.z_index = 100
		stroke.add_point(p)
		strokes_root.add_child(stroke)   # <-- was add_child(stroke)
		last_pos = p
		print("stroke started at ", p)
		return

	if p.distance_to(last_pos) >= MIN_DIST:
		_add_segment(last_pos, p)



func _add_segment(a: Vector2, b: Vector2) -> void:
	var ball: Node2D = get_node_or_null("Ball") as Node2D
	if ball != null:
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(ball.global_position, a, b)
		if closest.distance_to(ball.global_position) < BALL_CLEARANCE:
			print("segment skipped: too close to ball")
			last_pos = b
			stroke.add_point(b)
			return

	var length: float = a.distance_to(b)
	var shape := CapsuleShape2D.new()
	shape.radius = LINE_WIDTH * 0.5 + 2.0
	shape.height = length + shape.radius * 2.0

	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = (a + b) * 0.5
	cs.rotation = (b - a).angle() + PI * 0.5  # capsule's long axis is vertical by default
	wall_body.add_child(cs)

	stroke.add_point(b)
	last_pos = b
	print("segment added, total: ", wall_body.get_child_count())

func _on_target_body_entered(body: Node) -> void:
	if body.name != "Ball":
		return
	level += 1
	time_limit = max(MIN_TIME, time_limit - TIME_PER_LEVEL_REDUCTION)
	time_left = time_limit
	body.speed_up()
	_update_ui()

func _update_ui() -> void:
	level_label.text = str(level)
	time_label.text = str(ceili(time_left))

func _game_over() -> void:
	get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_game_over()
