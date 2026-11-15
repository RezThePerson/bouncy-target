extends Node2D

@onready var walls: StaticBody2D = $Walls
var last_pos := Vector2.ZERO
var drawing := false
var lines: Array[PackedVector2Array] = []  # for rendering

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		drawing = event.pressed
		last_pos = get_global_mouse_position()
	elif event is InputEventMouseMotion and drawing:
		var p := get_global_mouse_position()
		if p.distance_to(last_pos) > 8.0:
			_add_segment(last_pos, p)
			last_pos = p

func _add_segment(a: Vector2, b: Vector2):
	var shape := SegmentShape2D.new()
	shape.a = a
	shape.b = b
	var cs := CollisionShape2D.new()
	cs.shape = shape
	walls.add_child(cs)
	lines.append(PackedVector2Array([a, b]))
	queue_redraw()

func _draw():
	for l in lines:
		draw_line(l[0], l[1], Color.WHITE, 4.0)
