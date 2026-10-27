extends Node2D

const CELL_SIZE := 48

# Shape definitions: each is an Array of Vector2i cells
const SHAPES := {
	"briefcase": [
		# Handle: columns 2-3 at row 0
		Vector2i(2, 0), Vector2i(3, 0),
		# Body: columns 0-5 at rows 1-5
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
		Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2),
		Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3),
		Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4), Vector2i(5, 4),
		Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5),
	],
	"umbrella": [
		# Dome (5 rows, widening from 3 to 11)
		Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0),
		Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1),
		Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2),
		Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3), Vector2i(7, 3), Vector2i(8, 3), Vector2i(9, 3),
		Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4), Vector2i(8, 4), Vector2i(9, 4), Vector2i(10, 4),
		# Handle
		Vector2i(5, 5),
		Vector2i(5, 6),
		Vector2i(5, 7),
		Vector2i(5, 8),
		# Hook
		Vector2i(4, 9), Vector2i(5, 9),
	],
	"car": [
		# Cabin roof: columns 3-7 at rows 0-1
		Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0),
		Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1),
		# Body: columns 0-10 at rows 2-4
		Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2), Vector2i(9, 2), Vector2i(10, 2),
		Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3), Vector2i(7, 3), Vector2i(8, 3), Vector2i(9, 3), Vector2i(10, 3),
		Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4), Vector2i(8, 4), Vector2i(9, 4), Vector2i(10, 4),
		# Wheels
		Vector2i(1, 5), Vector2i(2, 5), Vector2i(8, 5), Vector2i(9, 5),
	],
}

# Current plate shape cells
var shape: Array[Vector2i] = []
# Tracks which cells are occupied
var occupied: Dictionary = {}  # Vector2i -> bool

func _ready() -> void:
	set_shape(SHAPES["briefcase"])

func set_shape(shape_cells: Array) -> void:
	shape.clear()
	for cell in shape_cells:
		shape.append(cell)
	occupied.clear()
	queue_redraw()

func _draw() -> void:
	for cell in shape:
		var rect := Rect2(Vector2(cell) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
		if occupied.has(cell):
			draw_rect(rect, Color(0.7, 0.7, 0.7))
		else:
			draw_rect(rect, Color(0.85, 0.85, 0.85))
		draw_rect(rect, Color(0.5, 0.5, 0.5), false, 2.0)

func can_place(block_cells: Array[Vector2i], grid_origin: Vector2i) -> bool:
	for cell in block_cells:
		var target := grid_origin + cell
		if target not in shape:
			return false
		if occupied.has(target):
			return false
	return true

func place_block(block_cells: Array[Vector2i], grid_origin: Vector2i) -> void:
	for cell in block_cells:
		var target := grid_origin + cell
		occupied[target] = true
	queue_redraw()

func unplace_block(block_cells: Array[Vector2i], grid_origin: Vector2i) -> void:
	for cell in block_cells:
		var target := grid_origin + cell
		occupied.erase(target)
	queue_redraw()

func get_snap_grid_pos(world_pos: Vector2) -> Vector2i:
	var local_pos := world_pos - global_position
	return Vector2i(roundi(local_pos.x / CELL_SIZE), roundi(local_pos.y / CELL_SIZE))

func get_cell_count() -> int:
	return shape.size()

func reset() -> void:
	occupied.clear()
	queue_redraw()
