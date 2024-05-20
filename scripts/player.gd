extends CharacterBody2D

@onready var building = $"../Building"

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var speed = 2

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = building.get_used_rect()
	astar_grid.cell_size = Vector2(16,16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar_grid.update()
	
	for x in building.get_used_rect().size.x:
		for y in building.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + building.get_used_rect().position.x,
				y + building.get_used_rect().position.y)
			var tile_data = building.get_cell_tile_data(0, tile_position)
			var tile_data2 = building.get_cell_tile_data(1, tile_position)
			if tile_data2 == null:
				if tile_data == null or tile_data.get_custom_data("walkable") == false:
					astar_grid.set_point_solid(tile_position)
			else: 
				if tile_data == null or tile_data.get_custom_data("walkable") == false or tile_data2.get_custom_data("is_wall"):
					astar_grid.set_point_solid(tile_position)

func _input(event):
	if event.is_action_pressed("left_click") == false:
		return
	
	var id_path = astar_grid.get_id_path(
		building.local_to_map(global_position),
		building.local_to_map(get_global_mouse_position())
	).slice(1)
	
	if id_path .is_empty() == false: 
		current_id_path = id_path
		
func _physics_process(delta):
	if current_id_path.is_empty() == true:
		return
	
	var target_position = building.map_to_local(current_id_path.front())
	global_position = global_position.move_toward(target_position, speed) 
	
	if global_position == target_position:
		current_id_path.pop_front()

