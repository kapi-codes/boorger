extends Node2D

const BLOCK_COLORS := [
	Color(1.0, 0.5, 0.45),   # coral
	Color(0.39, 0.58, 0.93),  # cornflower blue
	Color(0.58, 0.44, 0.86),  # medium purple
	Color(0.3, 0.85, 0.55),   # emerald
	Color(1.0, 0.75, 0.3),    # amber
	Color(0.9, 0.45, 0.7),    # pink
]

var food_block_script: GDScript = preload("res://food_block.gd")

func _ready() -> void:
	$PlateGrid.position = Vector2(560, 100)

	for i in 6:
		var block := Node2D.new()
		block.set_script(food_block_script)
		$BlockContainer.add_child(block)
		var col := i % 3
		var row := i / 3
		var x_pos := 30 + col * 160
		var y_pos := 80 + row * 200
		block.initialize(Vector2(x_pos, y_pos), BLOCK_COLORS[i], randi_range(2, 9))
