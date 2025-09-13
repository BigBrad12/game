extends Node2D

# Main scene script that sets up and manages the world generation system
# Updated to fix TileManager import issue

# Explicit preloads to ensure classes are available
const TileManagerScript = preload("res://TileManager.gd")
const WorldGeneratorScript = preload("res://WorldGenerator.gd")
const WorldRendererScript = preload("res://WorldRenderer.gd")

var world_renderer: WorldRenderer
var tile_manager: TileManager
var world_generator: WorldGenerator

func _ready():
	print("Starting Talu Game - World Generator")
	
	# Test if TileManager class is available
	print("Testing TileManager class availability...")
	var test_tile_manager = TileManager.new()
	if test_tile_manager:
		print("TileManager class is available!")
		test_tile_manager.queue_free()
	else:
		print("ERROR: TileManager class not available!")
	
	# Get references to the components (they're already in the scene)
	tile_manager = get_node("TileManager") as TileManager
	world_generator = get_node("WorldGenerator") as WorldGenerator
	world_renderer = get_node("WorldRenderer") as WorldRenderer
	
	if not tile_manager or not world_generator or not world_renderer:
		print("Error: Could not find required components!")
		return
	
	print("All components initialized successfully!")
	print("Controls:")
	print("- WASD or Arrow Keys: Move camera")
	print("- Mouse Wheel: Zoom in/out")
	print("- R: Regenerate world with new seed")

func _input(event):
	"""Handle global input events"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_F11:
			toggle_fullscreen()

func toggle_fullscreen():
	"""Toggle fullscreen mode"""
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
