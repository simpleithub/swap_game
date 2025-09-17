extends Node2D

# Board setup
var board = ["L","L","L","L","_","R","R","R","R"]
var slot_positions: Array = []
var tiles = []
var spacing = 80
var tile_size = Vector2(64, 64)

# Dragging
var dragging_tile = null
var drag_offset = Vector2.ZERO

func _ready():
	# Teal background
	var bg = ColorRect.new()
	bg.color = Color(0, 0.5, 0.5)
	bg.size = get_viewport().size
	bg.z_index = -1
	add_child(bg)
	
	# Calculate slot positions
	var num_slots = board.size()
	var screen_size = get_viewport().size
	var total_width = (num_slots - 1) * spacing
	var start_x = (screen_size.x - total_width) / 2
	var y = screen_size.y / 2
	
	for i in range(num_slots):
		var pos = Vector2(start_x + i * spacing, y)
		slot_positions.append(pos)
		
		# Optional: draw faint slot rectangles
		var slot_rect = ColorRect.new()
		slot_rect.color = Color(0.8, 0.8, 0.8, 0.2)
		slot_rect.size = tile_size
		slot_rect.position = pos - tile_size/2
		add_child(slot_rect)
	
	# Spawn tiles
	for i in range(num_slots):
		if board[i] != "_":
			var tile = Sprite2D.new()
			tile.texture = load("res://assets/%s.png" % board[i])
			tile.position = slot_positions[i]
			tile.centered = true
			tile.z_index = 1  # ensure tiles are on top
			# Store extra data using meta
			tile.set_meta("tile_type", board[i])
			tile.set_meta("slot_index", i)
			tiles.append(tile)
			add_child(tile)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Start dragging
			for tile in tiles:
				var rect = Rect2(tile.position - tile_size/2, tile_size)
				if rect.has_point(event.position):
					dragging_tile = tile
					drag_offset = tile.position - event.position
					break
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Release
			if dragging_tile:
				try_move(dragging_tile)
				dragging_tile = null

func _process(delta):
	if dragging_tile:
		dragging_tile.position = get_viewport().get_mouse_position() + drag_offset

# Check if the move is valid
func try_move(tile):
	var idx = tile.get_meta("slot_index")
	var empty_idx = board.find("_")
	var distance = abs(empty_idx - idx)
	
	if distance == 1:
		move_tile(tile, empty_idx)
	elif distance == 2:
		var middle_idx = int((idx + empty_idx)/2)
		if board[middle_idx] != tile.get_meta("tile_type"):
			move_tile(tile, empty_idx)
		else:
			# Invalid jump
			tile.position = slot_positions[idx]
	else:
		# Invalid move
		tile.position = slot_positions[idx]

func move_tile(tile, target_idx):
	# Update board array
	var idx = tile.get_meta("slot_index")
	var type = tile.get_meta("tile_type")
	board[idx] = "_"
	board[target_idx] = type
	
	# Update tile meta
	tile.set_meta("slot_index", target_idx)
	
	# Snap tile to slot position
	tile.position = slot_positions[target_idx]
