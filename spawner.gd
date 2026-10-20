extends Node2D

const CELL := 40

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 1.5
	timer.autostart = true
	timer.timeout.connect(_spawn)
	add_child(timer)

func _spawn() -> void:
	var piece := Piece.new()
	var max_x := get_viewport_rect().size.x - CELL * 3
	piece.position = Vector2(snappedf(randf_range(0, max_x), CELL), -CELL * 3)
	add_child(piece)
