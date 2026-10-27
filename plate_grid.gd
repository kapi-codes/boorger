extends Node2D

const CELL_SIZE := 48

# Briefcase shape: set of Vector2i cells that make up the plate
var shape: Array[Vector2i] = []
# Tracks which cells are occupied and their color
var occupied: Dictionary = {}  # Vector2i -> Color

func _ready() -> void:
	# Build briefcase shape: 2-wide handle at top, 6x5 body below
	# Handle: columns 2-3 at row 0
	for x in range(2, 4):
		shape.append(Vector2i(x, 0))
	# Body: columns 0-5 at rows 1-5
	for y in range(1, 6):
		for x in range(0, 6):
			shape.append(Vector2i(x, y))

func _draw() -> void:
	for cell in shape:
		var rect := Rect2(Vector2(cell) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
		if occupied.has(cell):
			draw_rect(rect, occupied[cell])
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

func place_block(block_cells: Array[Vector2i], grid_origin: Vector2i, color: Color) -> void:
	for cell in block_cells:
		var target := grid_origin + cell
		occupied[target] = color
	queue_redraw()

func unplace_block(block_cells: Array[Vector2i], grid_origin: Vector2i) -> void:
	for cell in block_cells:
		var target := grid_origin + cell
		occupied.erase(target)
	queue_redraw()

func get_snap_grid_pos(world_pos: Vector2) -> Vector2i:
	var local_pos := world_pos - global_position
	return Vector2i(roundi(local_pos.x / CELL_SIZE), roundi(local_pos.y / CELL_SIZE))
