extends TileMap

# Simple TileMap controller script
# Attach this to your TileMap node in the scene

var tile_manager: TileManager
var world_generator: WorldGenerator

func _ready():
	print("TileMapController ready!")
	
	# Get references to other components
	tile_manager = get_node("../TileManager") as TileManager
	world_generator = get_node("../WorldGenerator") as WorldGenerator
	
	if not tile_manager or not world_generator:
		print("Warning: Could not find TileManager or WorldGenerator")
		return
	
	# Wait for TileManager to set up its tileset
	call_deferred("connect_tileset")

func connect_tileset():
	"""Connect to the TileManager's tileset"""
	if tile_manager and tile_manager.biome_tileset:
		tile_set = tile_manager.biome_tileset
		print("TileMap tileset connected!")
	else:
		print("Warning: TileManager tileset not ready")

func render_world_data(world_data: Array[Array]):
	"""Render world data to the tilemap"""
	clear()
	
	var source_id = tile_manager.get_tile_source_id()
	
	for y in range(world_data.size()):
		for x in range(world_data[y].size()):
			var biome_type = world_data[y][x]
			var atlas_coords = tile_manager.get_tile_atlas_coords(biome_type)
			var tile_coords = Vector2i(x, y)
			
			set_cell(0, tile_coords, source_id, atlas_coords)
	
	print("World rendered to TileMap!")
