# Talu Game - World Generator

A procedural 100x100 tile world generator for Godot using sprite sheets.

## Setup Instructions

1. **Add Your Sprite Sheet:**
   - Place your 6-tile biome sprite sheet in the project (e.g., `sprites/biomes_sprite_sheet.png`)
   - Each tile should be 64x64 pixels
   - Tiles should be arranged horizontally: Grass, Forest, Mountain, Swamp, Desert, Water

2. **Configure Sprite Sheet Path:**
   - Open `TileManager.gd`
   - Update line 25 to point to your sprite sheet:
     ```gdscript
     sprite_sheet = load("res://sprites/your_sprite_sheet.png")
     ```
   - Uncomment the `setup_atlas()` call in `_ready()`

3. **Run the Project:**
   - Open project in Godot 4.3+
   - Press F5 to run

## Controls

- **WASD or Arrow Keys:** Move camera around the world
- **Mouse Wheel:** Zoom in/out
- **R:** Regenerate world with a new random seed
- **ESC:** Quit application
- **F11:** Toggle fullscreen

## Features

- **Procedural Generation:** Uses Perlin noise and cellular automata
- **Natural Biome Transitions:** Intelligent biome placement rules
- **Rivers and Lakes:** Automatic water feature generation
- **Weighted Distribution:** Configurable biome frequency
- **Real-time Navigation:** Smooth camera controls
- **Instant Regeneration:** Generate new worlds on demand

## Biome Types

1. **Grass** (30% weight) - Common base terrain
2. **Forest** (25% weight) - Clusters near grass and mountains
3. **Mountain** (15% weight) - Forms mountain ranges
4. **Swamp** (10% weight) - Appears near water and forests
5. **Desert** (15% weight) - Sparse, isolated regions
6. **Water** (5% weight) - Rivers, lakes, and coastal areas

## Customization

### Adjust Biome Weights
Edit the `biome_properties` dictionary in `TileManager.gd`:

```gdscript
var biome_properties = {
    BiomeType.GRASS: {"weight": 30, "adjacency_preference": [BiomeType.FOREST, BiomeType.DESERT]},
    # ... modify weights as desired
}
```

### Change World Size
Modify constants in `WorldGenerator.gd`:

```gdscript
const WORLD_WIDTH = 100  # Change to desired width
const WORLD_HEIGHT = 100 # Change to desired height
```

### Tune Generation Parameters
Adjust noise settings in `WorldGenerator.gd`:

```gdscript
var noise_scale: float = 0.1  # Smaller = larger features
var noise_thresholds = {
    "water": -0.3,    # Lower = more water
    "swamp": -0.1,    # Adjust thresholds as needed
    "desert": 0.3,
    "mountain": 0.7
}
```

## File Structure

- `Main.gd` - Main scene controller
- `TileManager.gd` - Handles sprite sheet and biome data
- `WorldGenerator.gd` - Procedural world generation logic
- `WorldRenderer.gd` - Renders and displays the world
- `Main.tscn` - Main scene file
- `project.godot` - Godot project configuration
