extends Node2D
class_name WorldRenderer

# References
var world_generator: WorldGenerator
var tile_manager: TileManager
var tile_map: TileMap

# Camera controls
var camera: Camera2D
var camera_speed: float = 300.0
var zoom_speed: float = 0.1
var min_zoom: float = 0.5
var max_zoom: float = 3.0

# World dimensions
const TILE_SIZE = 64

func _ready():
	setup_camera()
	setup_tilemap()
	
	# Get references to generator and tile manager
	world_generator = get_node("../WorldGenerator") as WorldGenerator
	tile_manager = get_node("../TileManager") as TileManager
	
	if not world_generator or not tile_manager:
		print("Error: WorldGenerator or TileManager not found!")
		return
	
	# Connect to world generation signal
	world_generator.world_generated.connect(_on_world_generated)
	
	# Generate the world
	world_generator.generate_world()

func setup_camera():
	"""Setup camera for world navigation"""
	camera = Camera2D.new()
	camera.name = "Camera"
	camera.zoom = Vector2(1.0, 1.0)
	add_child(camera)
	camera.make_current()

func setup_tilemap():
	"""Setup TileMap for world rendering"""
	tile_map = TileMap.new()
	tile_map.name = "WorldTileMap"
	add_child(tile_map)
	
	# Wait for tile_manager to be ready, then set the tileset
	call_deferred("setup_tileset_connection")

func setup_tileset_connection():
	"""Connect the tileset after TileManager is ready"""
	if tile_manager and tile_manager.biome_tileset:
		tile_map.tile_set = tile_manager.biome_tileset
		print("TileSet connected successfully!")
	else:
		print("Warning: TileManager or TileSet not ready yet")

func _on_world_generated():
	"""Called when world generation is complete"""
	print("Rendering world...")
	render_world()
	print("World rendering complete!")

func render_world():
	"""Render the entire world using TileMap"""
	clear_world()
	
	var world_data = world_generator.get_world_data()
	var world_size = world_generator.get_world_size()
	
	# Clear the tilemap
	tile_map.clear()
	
	# Set tiles for each biome
	for y in range(world_size.y):
		for x in range(world_size.x):
			var biome_type = world_data[y][x]
			set_tile_at_position(x, y, biome_type)

func set_tile_at_position(x: int, y: int, biome_type: TileManager.BiomeType):
	"""Set a tile at the specified position"""
	var tile_coords = Vector2i(x, y)
	var source_id = tile_manager.get_tile_source_id()
	var atlas_coords = tile_manager.get_tile_atlas_coords(biome_type)
	
	tile_map.set_cell(0, tile_coords, source_id, atlas_coords)

func clear_world():
	"""Clear all existing world tiles"""
	if tile_map:
		tile_map.clear()

func _input(event):
	"""Handle camera controls"""
	if not camera:
		return
	
	# Camera movement with WASD or arrow keys
	var movement = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_accept"):
		movement.y -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	
	# Apply movement
	camera.position += movement * camera_speed * get_process_delta_time()
	
	# Zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= (1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= (1.0 - zoom_speed)
		
		# Clamp zoom
		camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
		camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
	
	# Regenerate world with R key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			regenerate_world()

func regenerate_world():
	"""Regenerate the world with a new seed"""
	if world_generator:
		var new_seed = randi()
		world_generator.set_world_seed(new_seed)
		world_generator.generate_world()
		print("Regenerated world with seed: ", new_seed)

func center_camera_on_world():
	"""Center the camera on the generated world"""
	if camera and world_generator:
		var world_size = world_generator.get_world_size()
		var center_x = (world_size.x * TILE_SIZE) / 2.0
		var center_y = (world_size.y * TILE_SIZE) / 2.0
		camera.position = Vector2(center_x, center_y)

func get_tile_at_world_position(world_pos: Vector2) -> TileManager.BiomeType:
	"""Get the biome type at a specific world position"""
	if world_generator:
		var tile_x = int(world_pos.x / TILE_SIZE)
		var tile_y = int(world_pos.y / TILE_SIZE)
		return world_generator.get_tile_at_position(tile_x, tile_y)
	return TileManager.BiomeType.GRASS
