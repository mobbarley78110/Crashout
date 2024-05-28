extends CharacterBody2D

@onready var tile_set = $"../Building"
@onready var animated_sprite_2d = $AnimatedSprite2D

var astar_grid: AStarGrid2D
var selected_path: Array[Vector2i]
var available_path: Array[Vector2i]
var speed = 2

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_set.get_used_rect()
	astar_grid.cell_size = Vector2(16,16)
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
		selected_path = find_path()
		
	#TODO: if user uses keyboard to move (continuous movement)
	
func _physics_process(delta):

	# logic to move the player if a path was clicked
	if selected_path.is_empty() == false:
		# animate the player
		animated_sprite_2d.play('run')
		
		# move the player to the next step in the a* array
		var target_position = tile_set.map_to_local(selected_path.front())
		global_position = global_position.move_toward(target_position, speed) 		
		if global_position == target_position:
			selected_path.pop_front()
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

