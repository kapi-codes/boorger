class_name Piece
extends Node2D

const CELL := 40
const FALL_SPEED := 120.0

var cells: Array[Vector2i] = []
var landed := false
var passing := false  # slipped past the top of the stack: no collision, drawn behind

func _ready() -> void:
	var target := randi_range(2, 4)
	var dirs: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	cells.append(Vector2i(randi_range(0, 2), randi_range(0, 2)))
	while cells.size() < target:
		var options: Array[Vector2i] = []
		for c in cells:
			for d in dirs:
				var n: Vector2i = c + d
				var in_grid := n.x >= 0 and n.x <= 2 and n.y >= 0 and n.y <= 2
				if in_grid and n not in cells and n not in options:
					options.append(n)
		cells.append(options.pick_random())
	queue_redraw()

func _process(delta: float) -> void:
	if landed:
		return
	var dy := FALL_SPEED * delta
	position.y += dy

	if not passing:
		var player = get_tree().get_first_node_in_group("player")
		if player != null:
			var solids: Array[Rect2] = player.get_solid_rects()
			var land_overlap := 0.0
			var side_hit := false

			for mine in get_cell_rects():
				for solid in solids:
					if not mine.intersects(solid):
						continue
					# was this square still above the solid last frame?
					var was_above := mine.end.y - dy <= solid.position.y + 0.01
					if was_above:
						land_overlap = maxf(land_overlap, mine.end.y - solid.position.y)
					else:
						side_hit = true

			if land_overlap > 0.0:
				position.y -= land_overlap
				if _fits_stack(player):
					landed = true
					reparent(player)
				else:
					_reject()
				return
			elif side_hit:
				passing = true
				z_index = -1  # behind the player and the stack

	if position.y > get_viewport_rect().size.y:
		queue_free()

func get_cell_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for c in cells:
		rects.append(Rect2(global_position + Vector2(c) * CELL, Vector2(CELL, CELL)))
	return rects

func _fits_stack(player: Node) -> bool:
	var limits: Rect2 = player.get_stack_limits().grow(0.5)  # small tolerance for float error
	for r in get_cell_rects():
		if not limits.encloses(r):
			return false
	return true

func _reject() -> void:
	passing = true   # ignore the stack from now on and keep dropping
	z_index = -1
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.08)
	tween.tween_property(self, "modulate", Color.WHITE, 0.08)
	tween.tween_property(self, "modulate", Color.RED, 0.08)
	tween.tween_property(self, "modulate", Color.WHITE, 0.08)
	tween.tween_property(self, "modulate", Color.RED, 0.08)

func _draw() -> void:
	for c in cells:
		var rect := Rect2(Vector2(c) * CELL, Vector2(CELL, CELL))
		draw_rect(rect, Color.ORANGE)
		draw_rect(rect, Color.BLACK, false, 2.0)
