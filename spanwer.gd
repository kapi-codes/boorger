class_name Piece
extends Node2D

const CELL := 40
const FALL_SPEED := 120.0

var cells: Array[Vector2i] = []

func _ready() -> void:
	var all: Array[Vector2i] = []
	for x in 3:
		for y in 3:
			all.append(Vector2i(x, y))
	all.shuffle()
	cells.assign(all.slice(0, randi_range(2, 4)))  # 2 to 4 squares
	queue_redraw()

func _process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > get_viewport_rect().size.y:
		queue_free()

func _draw() -> void:
	for c in cells:
		var rect := Rect2(Vector2(c) * CELL, Vector2(CELL, CELL))
		draw_rect(rect, Color.ORANGE)
		draw_rect(rect, Color.BLACK, false, 2.0)
