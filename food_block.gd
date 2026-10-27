extends Node2D

const CELL_SIZE := 48

var cells: Array[Vector2i] = []
var block_color: Color
var home_position: Vector2
var dragging := false
var drag_offset := Vector2.ZERO
var placed := false

var plate_grid: Node2D

func initialize(pos: Vector2, color: Color, size: int) -> void:
	home_position = pos
	position = pos
	block_color = color
	_generate_polyomino(size)
	queue_redraw()

func _generate_polyomino(size: int) -> void:
	# Start at center of a 3x3 working area
	var used: Array[Vector2i] = [Vector2i(1, 1)]
	while used.size() < size:
		# Collect all unique neighbors of existing cells
		var neighbors: Array[Vector2i] = []
		for cell in used:
			for dir: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var n: Vector2i = cell + dir
				if n not in used and n not in neighbors:
					if n.x >= 0 and n.x < 3 and n.y >= 0 and n.y < 3:
						neighbors.append(n)
		if neighbors.is_empty():
			break
		used.append(neighbors[randi() % neighbors.size()])
	# Normalize to (0,0) origin
	var min_pos := used[0]
	for cell in used:
		min_pos = Vector2i(mini(min_pos.x, cell.x), mini(min_pos.y, cell.y))
	for i in used.size():
		cells.append(used[i] - min_pos)

func _draw() -> void:
	for cell in cells:
		var rect := Rect2(Vector2(cell) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
		draw_rect(rect, block_color)
		draw_rect(rect, block_color.darkened(0.3), false, 2.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not dragging:
			if _hit_test(event.global_position):
				if placed:
					# Pick up from plate
					plate_grid = get_node("/root/Main/PlateGrid")
					var grid_pos: Vector2i = plate_grid.get_snap_grid_pos(global_position)
					plate_grid.unplace_block(cells, grid_pos)
					placed = false
				dragging = true
				drag_offset = global_position - event.global_position
				# Render on top of siblings
				get_parent().move_child(self, -1)
				get_viewport().set_input_as_handled()
		elif not event.pressed and dragging:
			dragging = false
			_try_place()
			get_viewport().set_input_as_handled()

	elif event is InputEventKey and event.pressed and dragging:
		if event.keycode == KEY_RIGHT:
			_rotate_cells(true)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_LEFT:
			_rotate_cells(false)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and dragging:
		global_position = event.global_position + drag_offset
		get_viewport().set_input_as_handled()

func _rotate_cells(clockwise: bool) -> void:
	var rotated: Array[Vector2i] = []
	for cell in cells:
		if clockwise:
			rotated.append(Vector2i(-cell.y, cell.x))
		else:
			rotated.append(Vector2i(cell.y, -cell.x))
	# Normalize to (0,0) origin
	var min_pos := rotated[0]
	for cell in rotated:
		min_pos = Vector2i(mini(min_pos.x, cell.x), mini(min_pos.y, cell.y))
	for i in rotated.size():
		rotated[i] -= min_pos
	cells = rotated
	queue_redraw()

func _hit_test(mouse_pos: Vector2) -> bool:
	var local_mouse := mouse_pos - global_position
	for cell in cells:
		var rect := Rect2(Vector2(cell) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
		if rect.has_point(local_mouse):
			return true
	return false

func _try_place() -> void:
	plate_grid = get_node("/root/Main/PlateGrid")
	var grid_pos: Vector2i = plate_grid.get_snap_grid_pos(global_position)
	if plate_grid.can_place(cells, grid_pos):
		# Snap to grid
		global_position = plate_grid.global_position + Vector2(grid_pos) * CELL_SIZE
		plate_grid.place_block(cells, grid_pos, block_color)
		placed = true
	else:
		# Return to home
		position = home_position
