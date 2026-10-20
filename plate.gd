extends Node2D

const STEP := 40
const BODY_SIZE := Vector2(40, 40)  # set this to your character's size in pixels
const SCREEN_WIDTH := 1000
const MAX_STACK_HEIGHT := 3 * 40  # 3 squares of 40 px above the plate

func _ready() -> void:
	add_to_group("player")
	var screen_w := get_viewport_rect().size.x
	position.x = snappedf((screen_w - BODY_SIZE.x) / 2.0, STEP)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left", true):
		if position.x - STEP >= 0:
			position.x -= STEP
	elif event.is_action_pressed("ui_right", true):
		if position.x - STEP <= SCREEN_WIDTH:
			position.x += STEP
	elif event.is_action_pressed("ui_accept"):
		clear_stack()

func clear_stack() -> void:
	for child in get_children():
		if child is Piece:
			child.queue_free()
			
# the character's body plus every square of every piece stacked on it
func get_solid_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = [get_body_rect()]
	for child in get_children():
		if child is Piece:
			rects.append_array(child.get_cell_rects())
	return rects

func get_body_rect() -> Rect2:
	# 3 units wide: one unit left of the player, the player, one unit right
	return Rect2(global_position - Vector2(BODY_SIZE.x, 0), Vector2(BODY_SIZE.x * 3, BODY_SIZE.y))

func _draw() -> void:
	var side := Color(1, 1, 1, 0.15)
	draw_rect(Rect2(Vector2(-BODY_SIZE.x, 0), BODY_SIZE), side)
	draw_rect(Rect2(Vector2(BODY_SIZE.x, 0), BODY_SIZE), side)
	
# the area the stack is allowed to occupy
func get_stack_limits() -> Rect2:
	var base := get_body_rect()
	return Rect2(
		base.position.x,
		base.position.y - MAX_STACK_HEIGHT,
		base.size.x,
		base.size.y + MAX_STACK_HEIGHT
	)
