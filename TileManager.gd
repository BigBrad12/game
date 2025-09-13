extends Node2D
class_name TileManager

# Biome types
enum BiomeType {
	GRASS,
	FOREST,
	MOUNTAIN,
	SWAMP,
	DESERT,
	WATER
}

# Tile size from your sprite sheet
const TILE_SIZE = 64

# TileSet resource for the biomes
var biome_tileset: TileSet

# Dictionary to store biome properties for generation rules
var biome_properties = {
	BiomeType.GRASS: {"weight": 30, "adjacency_preference": [BiomeType.FOREST, BiomeType.DESERT]},
	BiomeType.FOREST: {"weight": 25, "adjacency_preference": [BiomeType.GRASS, BiomeType.MOUNTAIN]},
	BiomeType.MOUNTAIN: {"weight": 15, "adjacency_preference": [BiomeType.FOREST, BiomeType.GRASS]},
	BiomeType.SWAMP: {"weight": 10, "adjacency_preference": [BiomeType.WATER, BiomeType.FOREST]},
	BiomeType.DESERT: {"weight": 15, "adjacency_preference": [BiomeType.GRASS, BiomeType.MOUNTAIN]},
	BiomeType.WATER: {"weight": 5, "adjacency_preference": [BiomeType.SWAMP, BiomeType.GRASS]}
}

func _ready():
	# Create the TileSet resource
	setup_tileset()

func setup_tileset():
	"""Setup the TileSet from the sprite sheet"""
	biome_tileset = TileSet.new()
	
	# Create a TileSetAtlasSource for the sprite sheet
	var atlas_source = TileSetAtlasSource.new()
	
	# You'll need to load your sprite sheet here - replace with actual path
	# var sprite_sheet = load("res://sprites/biomes_sprite_sheet.png")
	# atlas_source.texture = sprite_sheet
	
	# For now, create a placeholder texture (you'll replace this)
	var placeholder_texture = ImageTexture.new()
	var image = Image.create(TILE_SIZE * 6, TILE_SIZE, false, Image.FORMAT_RGBA8)
	# Fill with different colors for each biome
	var colors = [Color.GREEN, Color.DARK_GREEN, Color.GRAY, Color.DARK_BLUE, Color.YELLOW, Color.BLUE]
	for i in range(6):
		for x in range(TILE_SIZE):
			for y in range(TILE_SIZE):
				image.set_pixel(i * TILE_SIZE + x, y, colors[i])
	placeholder_texture.set_image(image)
	atlas_source.texture = placeholder_texture
	
	# Configure each tile in the atlas
	for i in range(6):  # 6 biomes
		var atlas_coords = Vector2i(i, 0)
		atlas_source.create_tile(atlas_coords)
		var tile_data = atlas_source.get_tile_data(atlas_coords, 0)
		# Set up tile properties if needed
		tile_data.physics_layer = 0
		tile_data.physics_layer_0/0 = 0  # No collision for now
	
	# Add the atlas source to the tileset
	biome_tileset.add_source(atlas_source, 0)

func get_tile_source_id() -> int:
	"""Get the source ID for biome tiles"""
	return 0  # First (and only) source

func get_tile_atlas_coords(biome_type: BiomeType) -> Vector2i:
	"""Get the atlas coordinates for a specific biome type"""
	return Vector2i(biome_type, 0)

func get_biome_color(biome_type: BiomeType) -> Color:
	"""Get a representative color for each biome (for debugging/fallback)"""
	match biome_type:
		BiomeType.GRASS:
			return Color.GREEN
		BiomeType.FOREST:
			return Color.DARK_GREEN
		BiomeType.MOUNTAIN:
			return Color.GRAY
		BiomeType.SWAMP:
			return Color.DARK_BLUE
		BiomeType.DESERT:
			return Color.YELLOW
		BiomeType.WATER:
			return Color.BLUE
		_:
			return Color.WHITE

func get_weighted_random_biome() -> BiomeType:
	"""Get a random biome based on weights"""
	var total_weight = 0
	for biome in biome_properties:
		total_weight += biome_properties[biome]["weight"]
	
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for biome in biome_properties:
		current_weight += biome_properties[biome]["weight"]
		if random_value < current_weight:
			return biome
	
	return BiomeType.GRASS  # Fallback
