extends TileMap

# Límites de generación
export(int) var width_gen = 32
export(int) var height_gen = 24

# Parámetros de generación
export(int) var octaves = 0
export(int) var period = 6
export(float) var persistence = 0.2

export(bool) var regen setget _regen

# Elementos
var noise := OpenSimplexNoise.new()
const TILES = {
  'suelo': 0,
  'pared': 1
}

func _ready():
  randomize()
  generate()

func generate():
  # Setters
  noise.seed = randi()
  noise.octaves = self.octaves
  noise.period = self.period
  noise.persistence = self.persistence

  for x in range(0, self.width_gen):
    for y in range(0, self.height_gen):
      set_cell(x, y, noise.get_noise_2d(x, y) + 1)

func _regen(_x: int):
  generate()
