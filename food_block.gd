extends Node2D

const CELL_SIZE := 48

const FOOD_COLORS := {
	"cheese": Color(1.0, 0.85, 0.2),
	"meat": Color(0.72, 0.26, 0.18),
	"bread": Color(0.87, 0.72, 0.45),
	"burger": Color(0.55, 0.27, 0.07),
}

var cells: Array[Vector2i] = []
var food_items: Array = []  # Array of {type: String, cells: Array[Vector2i], text_angle: float}
var home_position: Vector2
var dragging := false
var drag_offset := Vector2.ZERO
var placed := false
var plate_grid: Node2D

func initialize(pos: Vector2, force_meat_stack: bool = false) -> void:
	home_position = pos
	position = pos
	if force_meat_stack:
		_generate_meat_stack()
	else:
		_generate_block()
	queue_redraw()

# Returns possible orientations for a food type as arrays of cell offsets
func _get_shapes(type: String) -> Array:
	match type:
		"bread":
			return [
				[Vector2i(0, 0), Vector2i(1, 0)],
				[Vector2i(0, 0), Vector2i(0, 1)],
			]
		"burger":
			return [
				[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
				[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			]
		_:
			return [[Vector2i(0, 0)]]

func _generate_meat_stack() -> void:
	food_items = []
	for y in 3:
		var item_cells: Array[Vector2i] = [Vector2i(0, y)]
		food_items.append({"type": "meat", "cells": item_cells, "text_angle": 0.0})
	_normalize_and_rebuild()

func _generate_block() -> void:
	var grid := {}
	food_items = []

	# Try to place a burger (25% chance)
	if randf() < 0.25:
		_try_place_food("burger", grid)

	# Try to place 0-1 breads
	for i in randi_range(0, 1):
		_try_place_food("bread", grid)

	# Fill some remaining cells with cheese/meat (70% chance each, biased toward meat)
	for y in 3:
		for x in 3:
			var cell := Vector2i(x, y)
			if not grid.has(cell) and randf() < 0.7:
				var type: String = "cheese" if randf() < 0.3 else "meat"
				var item_cells: Array[Vector2i] = [cell]
				food_items.append({"type": type, "cells": item_cells, "text_angle": 0.0})
				grid[cell] = true

	# Ensure at least 2 cells total
	if _total_cells() < 2:
		for y in 3:
			for x in 3:
				if _total_cells() >= 2:
					break
				var cell := Vector2i(x, y)
				if not grid.has(cell):
					var item_cells: Array[Vector2i] = [cell]
					food_items.append({"type": "cheese", "cells": item_cells, "text_angle": 0.0})
					grid[cell] = true
			if _total_cells() >= 2:
				break

	_normalize_and_rebuild()

func _try_place_food(type: String, grid: Dictionary) -> bool:
	var shapes: Array = _get_shapes(type)
	for attempt in 20:
		var shape: Array = shapes[randi() % shapes.size()]
		var origin := Vector2i(randi() % 3, randi() % 3)
		var fits := true
		for offset in shape:
			var pos: Vector2i = Vector2i(offset.x, offset.y) + origin
			if pos.x < 0 or pos.x >= 3 or pos.y < 0 or pos.y >= 3 or grid.has(pos):
				fits = false
				break
		if fits:
			var placed_cells: Array[Vector2i] = []
			for offset in shape:
				var pos: Vector2i = Vector2i(offset.x, offset.y) + origin
				grid[pos] = true
				placed_cells.append(pos)
			var angle: float = _compute_text_angle(shape)
			food_items.append({"type": type, "cells": placed_cells, "text_angle": angle})
			return true
	return false

func _compute_text_angle(shape: Array) -> float:
	if shape.size() <= 1:
		return 0.0
	var min_x: int = shape[0].x
	var max_x: int = min_x
	var min_y: int = shape[0].y
	var max_y: int = min_y
	for cell in shape:
		min_x = mini(min_x, cell.x)
		max_x = maxi(max_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_y = maxi(max_y, cell.y)
	if max_y - min_y > max_x - min_x:
		return PI / 2
	return 0.0

func _total_cells() -> int:
	var count := 0
	for item in food_items:
		var item_cells: Array = item.cells
		count += item_cells.size()
	return count

func _normalize_and_rebuild() -> void:
	var all_cells: Array[Vector2i] = []
	for item in food_items:
		for cell in item.cells:
			all_cells.append(Vector2i(cell.x, cell.y))
	if all_cells.is_empty():
		cells = []
		return
	var min_pos := all_cells[0]
	for cell in all_cells:
		min_pos = Vector2i(mini(min_pos.x, cell.x), mini(min_pos.y, cell.y))
	for item in food_items:
		var item_cells: Array = item.cells
		for i in item_cells.size():
			var c: Vector2i = Vector2i(item_cells[i].x, item_cells[i].y)
			item_cells[i] = c - min_pos
	cells = []
	for item in food_items:
		for cell in item.cells:
			cells.append(Vector2i(cell.x, cell.y))

func _draw() -> void:
	# Draw cell backgrounds
	for item in food_items:
		var color: Color = FOOD_COLORS[item.type]
		for cell in item.cells:
			var rect := Rect2(Vector2(cell.x, cell.y) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
			draw_rect(rect, color)
			draw_rect(rect, color.darkened(0.3), false, 2.0)

	# Draw text labels
	var font: Font = ThemeDB.fallback_font
	for item in food_items:
		var text: String = item.type.to_upper()
		var center: Vector2 = _get_item_center_px(item)
		var font_size: int = _get_font_size(item.type)
		var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var angle: float = item.text_angle
		draw_set_transform(center, angle)
		draw_string(font, Vector2(-text_size.x / 2, text_size.y / 4), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0)

func _get_item_center_px(item: Dictionary) -> Vector2:
	var item_cells: Array = item.cells
	var first_x: int = item_cells[0].x
	var first_y: int = item_cells[0].y
	var min_x := first_x
	var max_x := first_x
	var min_y := first_y
	var max_y := first_y
	for cell in item_cells:
		min_x = mini(min_x, cell.x)
		max_x = maxi(max_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_y = maxi(max_y, cell.y)
	var top_left := Vector2(min_x, min_y) * CELL_SIZE
	var bottom_right := Vector2(max_x + 1, max_y + 1) * CELL_SIZE
	return (top_left + bottom_right) / 2.0

func _get_font_size(type: Variant) -> int:
	match type:
		"burger":
			return 16
		"bread":
			return 13
		_:
			return 10

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not dragging:
			if _hit_test(event.global_position):
				if placed:
					plate_grid = get_node("/root/Main/PlateGrid")
					var grid_pos: Vector2i = plate_grid.get_snap_grid_pos(global_position)
					plate_grid.unplace_block(cells, grid_pos)
					placed = false
				dragging = true
				drag_offset = global_position - event.global_position
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
	for item in food_items:
		var item_cells: Array = item.cells
		var rotated: Array[Vector2i] = []
		for cell in item_cells:
			var c := Vector2i(cell.x, cell.y)
			if clockwise:
				rotated.append(Vector2i(-c.y, c.x))
			else:
				rotated.append(Vector2i(c.y, -c.x))
		item.cells = rotated
		var angle: float = item.text_angle
		item.text_angle = angle + (PI / 2 if clockwise else -PI / 2)
	_normalize_and_rebuild()
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
		global_position = plate_grid.global_position + Vector2(grid_pos) * CELL_SIZE
		plate_grid.place_block(cells, grid_pos)
		placed = true
	else:
		position = home_position
