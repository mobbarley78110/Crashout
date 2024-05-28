extends TileMap

var grid_size: int

func _ready():
	grid_size = self.rendering_quadrant_size

func _physics_process(_delta):
	# display white cursor where player can walk
	var mouse_pos = get_local_mouse_position() # position of the mouse on the grid
	var tile_pos = local_to_map(mouse_pos) # tile x,y coords on the grid
	var tile_data_floor = get_cell_tile_data(0, tile_pos) # data of that tile
	var tile_data_wall = get_cell_tile_data(1, tile_pos) # data of that tile
	clear_layer(3)
	# find out rules for walkable and is_wall
	var a :bool = false
	var b :bool = false
	var can_go :bool = false
	if tile_data_floor is TileData:
		a = tile_data_floor.get_custom_data("walkable")
	if tile_data_wall is TileData:
		b = tile_data_wall.get_custom_data("is_wall")
	can_go = a and !b
	if can_go:
		set_cell(3, tile_pos, 0, Vector2(67,1), 0)
	if not(can_go):
		set_cell(3, tile_pos, 0, Vector2(69,1), 0)
