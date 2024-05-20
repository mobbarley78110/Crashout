extends TileMap
@onready var cursor = $"../UI/Cursor"
@onready var mouse_pos_label = $"../UI/VBoxContainer/Mouse Pos Label"
@onready var tile_pos_label = $"../UI/VBoxContainer/Tile Pos Label"
@onready var camera_2d = $"../Player/Camera2D"
var grid_size: int

func _ready():
	cursor.visible = false
	grid_size = self.rendering_quadrant_size

func _physics_process(_delta):
	# display white cursor where player can walk
	var mouse_pos = get_viewport().get_mouse_position()
	var tile_pos = local_to_map(mouse_pos)
	var tile_data = get_cell_tile_data(0, tile_pos)
	if tile_data is TileData:
		if tile_data.get_custom_data("walkable") == true && tile_data.get_custom_data("is_wall") == false:
			# display little square
			mouse_pos_label.text = str(mouse_pos.x) + ", " +  str(mouse_pos.y)
			tile_pos_label.text = str(tile_pos.x) + ", " +  str(tile_pos.y) 
			cursor.position = map_to_local(tile_pos)# - Vector2(grid_size,grid_size)
			cursor.visible = true
		else:
			cursor.visible = false
		
		#cursor.visible = true
