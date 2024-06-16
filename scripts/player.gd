extends CharacterBody2D

@onready var tile_set = $"../Building"
@onready var animated_sprite_2d = $AnimatedSprite2D

var astar_grid: AStarGrid2D
var selected_path: Array[Vector2i]
var available_path: Array[Vector2i]
var speed = 2
var cell_size :int
var want_to_stop:bool = false
var first_movement:bool = true
var patience_time: int = 2
var time_since_last_move: float = 0

signal tile_reached

func _ready():
	cell_size = tile_set.rendering_quadrant_size
	# Initiate a* system
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_set.get_used_rect()
	astar_grid.cell_size = Vector2(cell_size, cell_size)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar_grid.update()
	
	# iterate over all tiles to see which ones are walkable 
	# so they can be added to the a* "good tiles to use" 
	#TODO: add weight for slow moving tiles if exist
	for x in tile_set.get_used_rect().size.x:
		for y in tile_set.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_set.get_used_rect().position.x,
				y + tile_set.get_used_rect().position.y)
			var tile_data_floor = tile_set.get_cell_tile_data(0, tile_position)
			var tile_data_wall = tile_set.get_cell_tile_data(1, tile_position)
			# test if the tile is walkable
			var can_walk: bool = false
			var a: bool = false
			var b: bool = false
			if tile_data_floor:
				if tile_data_floor.get_custom_data("walkable") == true:
					a = true
			if tile_data_wall:
				if tile_data_wall.get_custom_data("is_wall"):
					b = true
			can_walk = a and not(b)
			if !can_walk:
				astar_grid.set_point_solid(tile_position)


func _input(event):
	# if user **clicks on a good walkable tile
	if event.is_action_pressed("left_click") == true:
		# if there's already a path happening, cancel it
		if  selected_path.is_empty() == false:
			want_to_stop = true
		# else, start a new path
		else:
			selected_path = find_path()

	# manage Keyboard movement
	elif event.is_action_pressed("right") == true:
		first_movement = true
		move(Vector2.RIGHT)
	elif event.is_action_pressed("left") == true:
		first_movement = true
		move(Vector2.LEFT)
	elif event.is_action_pressed("up") == true:
		first_movement = true
		move(Vector2.UP)
	elif  event.is_action_pressed("down") == true:
		first_movement = true
		move(Vector2.DOWN)

	# TODO: move that to "moving" state machine 
	# because that's going to be a bitch to manage
	if event.is_action_pressed("pause") == true:
		want_to_stop = true


func _process(delta):
	
	# smoke if we dont move after n seconds

	
	# logic to move the player if a path was clicked
	# if the path isn't emptuy, we move the player.
	if selected_path.is_empty() == false:
		# animate the player
		animated_sprite_2d.play('run')
		# move the player to the next step in the a* array
		var target_position = tile_set.map_to_local(selected_path.front())
		global_position = global_position.move_toward(target_position, speed) 
		if global_position == target_position: # we reached the next tile in path
			tile_reached.emit()
			stop_movement() # will stop at next tile if it was requested
			selected_path.pop_front()
	else:
		
		time_since_last_move+= delta
		if time_since_last_move > patience_time :
			print('smoke')
			animated_sprite_2d.play('smoke')
			#time_since_last_move = 0
		else:
			animated_sprite_2d.play('idle')
		
		# get position of mouse and show an a* path if exist
		available_path = find_path()
		for p in available_path:
			# draw a little blob on each tile of the path
			tile_set.set_cell(3, p, 1, Vector2(4,0), 0)


func find_path() -> Array[Vector2i]:
	var _rez:Array[Vector2i]
	var id_path = astar_grid.get_id_path(
			tile_set.local_to_map(global_position),
			tile_set.local_to_map(get_global_mouse_position())
		).slice(1) # Remove the first element of the path (the current position)
	if id_path .is_empty() == false: 
		return id_path
	else: 
		return _rez


func stop_movement():
	if want_to_stop == true:
		selected_path = []
		available_path = []
		want_to_stop = false


func move(direction: Vector2i):
	# get current tile
	var current_tile: Vector2i = tile_set.local_to_map(global_position) 
	# get target tile
	var target_tile: Vector2i = current_tile + direction
	# test if target tile is walkable and move to it
	var target_is_walkable = walkable_test(target_tile)
	if target_is_walkable == true:
		# add target tile to path, only if there's nothing in there
		if len(selected_path) <= 1:  # TODO: this still allows bugs 
			selected_path += [target_tile]
	
	
func walkable_test(target_tile_pos: Vector2i) -> bool:
	var tile_data_floor = tile_set.get_cell_tile_data(0, target_tile_pos)
	var tile_data_wall = tile_set.get_cell_tile_data(1, target_tile_pos)
	var can_walk: bool = false
	var a: bool = false
	var b: bool = false
	if tile_data_floor:
		if tile_data_floor.get_custom_data("walkable") == true:
			a = true
	if tile_data_wall:
		if tile_data_wall.get_custom_data("is_wall"):
			b = true
	can_walk = a and not(b)
	if !can_walk:
		return false
	else:
		return true	


func _on_tile_reached():
	
	# continue movement if keys are still pressed
	if first_movement == true: 
		await get_tree().create_timer(0.2).timeout 
	if Input.is_action_pressed('right') == true:
		first_movement = false
		move(Vector2.RIGHT)
	elif Input.is_action_pressed('left') == true:
		first_movement = false
		move(Vector2.LEFT)
	elif Input.is_action_pressed('up') == true:
		first_movement = false
		move(Vector2.UP)
	elif Input.is_action_pressed('down') == true:
		first_movement = false
		move(Vector2.DOWN)
		
