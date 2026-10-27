extends Node2D

var food_block_script: GDScript = preload("res://food_block.gd")
var game_state: String = "playing"
var total_score: int = 0

const PLATE_SHAPES: Array[String] = ["briefcase", "umbrella", "car"]
var shape_index: int = 0

func _ready() -> void:
	$PlateGrid.position = Vector2(560, 100)

	_spawn_blocks()

	$SubmitButton.pressed.connect(_on_submit_pressed)
	_update_score_label()

func _spawn_blocks() -> void:
	var meat_stack_index := randi() % 6
	for i in 6:
		_spawn_block(i, i == meat_stack_index)

func _spawn_block(i: int, force_meat_stack: bool = false) -> void:
	var block := Node2D.new()
	block.set_script(food_block_script)
	$BlockContainer.add_child(block)
	var col := i % 3
	var row := i / 3
	var x_pos := 30 + col * 160
	var y_pos := 80 + row * 200
	block.initialize(Vector2(x_pos, y_pos), force_meat_stack)

func _update_score_label() -> void:
	$ScoreLabel.text = "Score: " + str(total_score)

func _on_submit_pressed() -> void:
	if game_state == "playing":
		var round_score := _score_plate()
		total_score += round_score
		_update_score_label()
		game_state = "scored"
		$SubmitButton.text = "Next Plate"
	elif game_state == "scored":
		_reset_round()
		game_state = "playing"
		$SubmitButton.text = "Submit Plate"

func _score_plate() -> int:
	var plate_grid: Node2D = $PlateGrid
	# Build a map of grid cell -> food type from placed blocks
	var cell_types: Dictionary = {}  # Vector2i -> String
	for block in $BlockContainer.get_children():
		if not block.placed:
			continue
		var grid_origin: Vector2i = plate_grid.get_snap_grid_pos(block.global_position)
		for item in block.food_items:
			for cell in item.cells:
				var target := grid_origin + Vector2i(cell.x, cell.y)
				cell_types[target] = item.type

	var score := 0
	var covered := 0
	var uncovered := 0
	var burger_bonus := 0

	for cell in plate_grid.shape:
		if cell_types.has(cell):
			covered += 1
			if cell_types[cell] == "burger":
				burger_bonus += 1
		else:
			uncovered += 1

	score = covered - uncovered + burger_bonus

	var sandwich_count := _check_burger_sandwich(cell_types)
	var sandwich_bonus := sandwich_count * 10
	score += sandwich_bonus

	# Build message
	var msg := "Round: " + ("+" if score >= 0 else "") + str(score)
	msg += "\n  Covered: +" + str(covered)
	msg += "  Empty: -" + str(uncovered)
	if burger_bonus > 0:
		msg += "\n  Burger bonus: +" + str(burger_bonus)
	if sandwich_count > 0:
		msg += "\n  Burger Sandwich found! +" + str(sandwich_bonus)
	$MessageLabel.text = msg

	return score

func _check_burger_sandwich(cell_types: Dictionary) -> int:
	var count := 0

	# Collect all cell positions to find scan bounds
	var all_cells: Array = cell_types.keys()
	if all_cells.is_empty():
		return 0

	var min_x: int = all_cells[0].x
	var max_x: int = min_x
	var min_y: int = all_cells[0].y
	var max_y: int = min_y
	for cell in all_cells:
		min_x = mini(min_x, cell.x)
		max_x = maxi(max_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_y = maxi(max_y, cell.y)

	# Horizontal pattern: 5 wide x 3 tall
	# cols 0-1: burger, col 2: meat, cols 3-4: burger
	for y in range(min_y, max_y - 1):
		for x in range(min_x, max_x - 3):
			if _check_h_sandwich(cell_types, x, y):
				count += 1

	# Vertical pattern: 3 wide x 5 tall
	# rows 0-1: burger, row 2: meat, rows 3-4: burger
	for y in range(min_y, max_y - 3):
		for x in range(min_x, max_x - 1):
			if _check_v_sandwich(cell_types, x, y):
				count += 1

	return count

func _check_h_sandwich(cell_types: Dictionary, x: int, y: int) -> bool:
	# 5 wide x 3 tall: cols 0-1 burger, col 2 meat, cols 3-4 burger
	for row in 3:
		for col in 2:
			var cell := Vector2i(x + col, y + row)
			if not cell_types.has(cell) or cell_types[cell] != "burger":
				return false
		var meat_cell := Vector2i(x + 2, y + row)
		if not cell_types.has(meat_cell) or cell_types[meat_cell] != "meat":
			return false
		for col in range(3, 5):
			var cell := Vector2i(x + col, y + row)
			if not cell_types.has(cell) or cell_types[cell] != "burger":
				return false
	return true

func _check_v_sandwich(cell_types: Dictionary, x: int, y: int) -> bool:
	# 3 wide x 5 tall: rows 0-1 burger, row 2 meat, rows 3-4 burger
	for col in 3:
		for row in 2:
			var cell := Vector2i(x + col, y + row)
			if not cell_types.has(cell) or cell_types[cell] != "burger":
				return false
		var meat_cell := Vector2i(x + col, y + 2)
		if not cell_types.has(meat_cell) or cell_types[meat_cell] != "meat":
			return false
		for row in range(3, 5):
			var cell := Vector2i(x + col, y + row)
			if not cell_types.has(cell) or cell_types[cell] != "burger":
				return false
	return true

func _reset_round() -> void:
	# Remove all existing blocks
	for block in $BlockContainer.get_children():
		block.queue_free()

	# Cycle to the next plate shape
	shape_index = (shape_index + 1) % PLATE_SHAPES.size()
	var plate_grid: Node2D = $PlateGrid
	plate_grid.set_shape(plate_grid.SHAPES[PLATE_SHAPES[shape_index]])

	# Spawn new blocks (deferred so old ones are freed first)
	_spawn_new_blocks.call_deferred()

	# Clear message
	$MessageLabel.text = ""

func _spawn_new_blocks() -> void:
	_spawn_blocks()
