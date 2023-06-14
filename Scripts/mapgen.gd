extends Node2D

const STEPS = 3
var DIRECTIONS = [
  Vector2.UP,
  Vector2.UP + Vector2.RIGHT,
  Vector2.RIGHT,
  Vector2.DOWN + Vector2.RIGHT,
  Vector2.DOWN,
  Vector2.DOWN + Vector2.LEFT,
  Vector2.LEFT,
  Vector2.UP + Vector2.LEFT
]

export var MAP_WIDTH := 48
export var MAP_HEIGHT := 36
export var INITIAL_LIFE_CHANCE := 0.375
export var BIRTH_LIMIT = 4
export var DEATH_LIMIT = 3

var cellmap := []
var astar = AStar2D.new()
onready var tilemap := $TileMap

signal map_ready

func _ready():
  randomize()
  _generate_grid()
  _generate_map()
  for _x in range(STEPS): # Shape the og grid into a cave-looking map
    _simulation_step()
  _print_map()
  global.map = cellmap

  global.player_spawn = _random_spawn()
  global.exit_spawn = _random_spawn()
  emit_signal("map_ready")


# Debug keys to test and tweak with the mapgen
func _unhandled_input(event):
  if event.is_action_pressed("key_f1"):
    _generate_map()
    _print_map()

  if event.is_action_pressed("key_f2"):
    _simulation_step()
    _print_map()

  if event.is_action_pressed("key_f3"):
    _ready()


# Creates a 2D Array grid
func _generate_grid():
  for i in MAP_WIDTH:
    cellmap.append([])
    for j in MAP_HEIGHT:
      cellmap[i].append(0)


# Populates the grid with random values
func _generate_map():
  for x in range(MAP_WIDTH):
    for y in range(MAP_HEIGHT):
      if randf() < INITIAL_LIFE_CHANCE:
        cellmap[x][y] = 1
      else:
        cellmap[x][y] = 0


# Runs the GoL ruleset (see variables) on the current map
# Returns the resulting map
func _simulation_step():
  var cellmap_process = cellmap.duplicate(true)

  for x in MAP_WIDTH:
    for y in MAP_HEIGHT:
      var current_tile = cellmap_process[x][y]
      var neighbors = _count_alive_neighbors(x, y)
      if (cellmap[x][y] == 1):
        # Tile's alive, changes by death rules
        if (neighbors < DEATH_LIMIT):
          current_tile = 0
        else:
          current_tile = 1
      else:
        # Tile's dead, changes by birth rules
        if (neighbors > BIRTH_LIMIT):
          current_tile = 1
        else:
          current_tile = 0
      cellmap_process[x][y] = current_tile

  cellmap = cellmap_process


# Returns the number of 'alive' cells neighboring the param cell
func _count_alive_neighbors(x: int, y: int) -> int:
  var count_alive := 0

  for i in range(-1, 2):
    for j in range(-1, 2):
      var relative_x = x + i
      var relative_y = y + j

      if (i == 0 and j == 0):
        # We're checking our own tile
        continue
      elif (relative_x < 0 or relative_y < 0
        or relative_x >= MAP_WIDTH or relative_y >= MAP_HEIGHT):
        # The tile to check is off-limits, count that as a wall
        count_alive += 1
      elif (cellmap[relative_x][relative_y]):
        count_alive += 1

  return count_alive


# Prints the map onto the screen using its tilemap
func _print_map():
  for x in MAP_WIDTH:
    for y in MAP_HEIGHT:
      tilemap.set_cell(x, y, cellmap[x][y])


# Selects a random spawn position for a thing
func _random_spawn() -> Vector2:
  var spawn_x: int
  var spawn_y: int
  var is_tile_available = 1 # wall

  while is_tile_available:
    spawn_x = randi() % MAP_WIDTH
    spawn_y = randi() % MAP_HEIGHT
    is_tile_available = cellmap[spawn_x][spawn_y]

  var spawn = Vector2(spawn_x, spawn_y)
  print (spawn)
  return spawn
