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
  _generate()
  
  Global.map = _save_map()
  Global.first_floor = _find_first_floor()


func _unhandled_input(event):
  if Input.is_key_pressed(KEY_F5):
    _regen(0)


func _generate():
  # Setters
  noise.seed = randi()
  noise.octaves = self.octaves
  noise.period = self.period
  noise.persistence = self.persistence

  for x in range(0, self.width_gen):
    for y in range(0, self.height_gen):
      set_cell(x, y, noise.get_noise_2d(x, y) + 1)


func _regen(_x: int):
  _generate()

func _find_first_floor():
  for y in range(0, self.height_gen):
    for x in range(0, self.width_gen):
      if get_cell(x, y) == TILES.suelo:
        return Vector2(float(x), float(y))


func _save_map():
  var map = []

  for x in range(height_gen):
    var col = []
    col.resize(width_gen)
    map.append(col)

  for y in range(0, self.height_gen):
    for x in range(0, self.width_gen):
      map[y][x] = get_cell(x, y)

  return map
