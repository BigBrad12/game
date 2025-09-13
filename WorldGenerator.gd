extends Node2D
class_name WorldGenerator

# World dimensions
const WORLD_WIDTH = 100
const WORLD_HEIGHT = 100

# References
var tile_manager: TileManager
var world_tiles: Array[Array] = []

# Generation parameters
var noise_seed: int = 12345
var noise_scale: float = 0.1
var noise_thresholds = {
	"water": -0.3,
	"swamp": -0.1,
	"desert": 0.3,
	"mountain": 0.7
}

# Signals
signal world_generated

func _ready():
	tile_manager = get_node("TileManager") as TileManager
	if not tile_manager:
		print("Error: TileManager not found!")

func generate_world():
	"""Generate a 100x100 world map"""
	print("Starting world generation...")
	
	# Initialize the world array
	world_tiles.clear()
	for y in range(WORLD_HEIGHT):
		var row: Array = []
		for x in range(WORLD_WIDTH):
			row.append(TileManager.BiomeType.GRASS)  # Default biome
		world_tiles.append(row)
	
	# Create noise for natural generation
	var noise = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.frequency = noise_scale
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	# Generate biomes based on noise
	generate_biomes_with_noise(noise)
	
	# Apply cellular automata for more natural transitions
	apply_cellular_automata(3)  # 3 iterations
	
	# Create rivers and lakes
	generate_water_features(noise)
	
	# Final smoothing pass
	apply_cellular_automata(1)
	
	print("World generation complete!")
	world_generated.emit()

func generate_biomes_with_noise(noise: FastNoiseLite):
	"""Generate initial biome placement using Perlin noise"""
	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			var noise_value = noise.get_noise_2d(x, y)
			var biome_type = get_biome_from_noise(noise_value)
			world_tiles[y][x] = biome_type

func get_biome_from_noise(noise_value: float) -> TileManager.BiomeType:
	"""Convert noise value to biome type"""
	if noise_value < noise_thresholds["water"]:
		return TileManager.BiomeType.WATER
	elif noise_value < noise_thresholds["swamp"]:
		return TileManager.BiomeType.SWAMP
	elif noise_value > noise_thresholds["mountain"]:
		return TileManager.BiomeType.MOUNTAIN
	elif noise_value > noise_thresholds["desert"]:
		return TileManager.BiomeType.DESERT
	else:
		# Use weighted random for grass/forest
		return tile_manager.get_weighted_random_biome()

func apply_cellular_automata(iterations: int):
	"""Apply cellular automata rules for natural biome transitions"""
	for iteration in range(iterations):
		var new_world = world_tiles.duplicate(true)
		
		for y in range(1, WORLD_HEIGHT - 1):
			for x in range(1, WORLD_WIDTH - 1):
				var neighbors = get_neighboring_biomes(x, y)
				new_world[y][x] = apply_automata_rules(world_tiles[y][x], neighbors)
		
		world_tiles = new_world

func get_neighboring_biomes(x: int, y: int) -> Array:
	"""Get the 8 neighboring biome types around a position"""
	var neighbors = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < WORLD_WIDTH and ny >= 0 and ny < WORLD_HEIGHT:
				neighbors.append(world_tiles[ny][nx])
	return neighbors

func apply_automata_rules(current_biome: TileManager.BiomeType, neighbors: Array) -> TileManager.BiomeType:
	"""Apply cellular automata rules to determine new biome"""
	var biome_counts = {}
	
	# Count neighboring biomes
	for biome in neighbors:
		biome_counts[biome] = biome_counts.get(biome, 0) + 1
	
	# Special rules for water - water spreads if surrounded by water
	if current_biome == TileManager.BiomeType.WATER:
		if biome_counts.get(TileManager.BiomeType.WATER, 0) >= 4:
			return TileManager.BiomeType.WATER
		elif biome_counts.get(TileManager.BiomeType.SWAMP, 0) >= 3:
			return TileManager.BiomeType.SWAMP
	
	# Mountain formation - mountains cluster together
	if current_biome == TileManager.BiomeType.MOUNTAIN:
		if biome_counts.get(TileManager.BiomeType.MOUNTAIN, 0) >= 3:
			return TileManager.BiomeType.MOUNTAIN
		elif biome_counts.get(TileManager.BiomeType.FOREST, 0) >= 4:
			return TileManager.BiomeType.FOREST
	
	# Forest spreads to adjacent areas
	if current_biome == TileManager.BiomeType.GRASS:
		if biome_counts.get(TileManager.BiomeType.FOREST, 0) >= 3:
			return TileManager.BiomeType.FOREST
	
	# Desert isolation - deserts don't spread easily
	if current_biome == TileManager.BiomeType.DESERT:
		if biome_counts.get(TileManager.BiomeType.DESERT, 0) >= 4:
			return TileManager.BiomeType.DESERT
	
	return current_biome

func generate_water_features(noise: FastNoiseLite):
	"""Generate rivers and lakes using additional noise"""
	var river_noise = FastNoiseLite.new()
	river_noise.seed = noise_seed + 1000
	river_noise.frequency = 0.05
	river_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			var river_value = abs(river_noise.get_noise_2d(x, y))
			var current_biome = world_tiles[y][x]
			
			# Create rivers in low-lying areas
			if river_value < 0.1 and current_biome in [TileManager.BiomeType.GRASS, TileManager.BiomeType.FOREST]:
				world_tiles[y][x] = TileManager.BiomeType.WATER

func get_tile_at_position(x: int, y: int) -> TileManager.BiomeType:
	"""Get the biome type at a specific world position"""
	if x >= 0 and x < WORLD_WIDTH and y >= 0 and y < WORLD_HEIGHT:
		return world_tiles[y][x]
	return TileManager.BiomeType.GRASS

func get_world_data() -> Array[Array]:
	"""Get the complete world data"""
	return world_tiles

func set_world_seed(new_seed: int):
	"""Set a new seed for world generation"""
	noise_seed = new_seed

func get_world_size() -> Vector2:
	"""Get the world dimensions"""
	return Vector2(WORLD_WIDTH, WORLD_HEIGHT)
