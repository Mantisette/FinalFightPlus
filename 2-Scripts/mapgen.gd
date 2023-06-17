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

export var INITIAL_LIFE_CHANCE := 0.375
export var BIRTH_LIMIT = 4
export var DEATH_LIMIT = 3

var cellmap := []
onready var tilemap := $TileMap
signal map_ready

onready var player_spawn_pos: Vector2
onready var exit_spawn_pos: Vector2
onready var enemy_spawn_pos: Vector2


func _ready():
  randomize()
  _generate_grid()
  _generate_map()

  for _x in range(STEPS): # Shape the og grid into a cave-looking map
    _simulation_step()
  _close_borders()

  _print_map()
  global.cellmap = cellmap

  global.astar_ready()

  emit_signal("map_ready")
  
  if !_check_spawn_positions():
    return
  var player_path = global.astar_find_path(player_spawn_pos, exit_spawn_pos)
  var enemy_path = global.astar_find_path(enemy_spawn_pos, player_spawn_pos)
  if player_path == [] or enemy_path == []:
    _ready()


func _check_spawn_positions() -> bool:
  return (player_spawn_pos != null and exit_spawn_pos != null and enemy_spawn_pos != null)


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
  for i in global.MAP_WIDTH:
    cellmap.append([])
    for j in global.MAP_HEIGHT:
      cellmap[i].append(0)


# Populates the grid with random values
func _generate_map():
  for x in range(global.MAP_WIDTH):
    for y in range(global.MAP_HEIGHT):
      if randf() < INITIAL_LIFE_CHANCE:
        cellmap[x][y] = 1
      else:
        cellmap[x][y] = 0


# Runs the GoL ruleset (see variables) on the current map
# Returns the resulting map
func _simulation_step():
  var cellmap_process = cellmap.duplicate(true)

  for x in global.MAP_WIDTH:
    for y in global.MAP_HEIGHT:
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
      var local_x = x + i
      var local_y = y + j

      if (i == 0 and j == 0):
        # We're checking our own tile
        continue
      elif (global.is_tile_off_bounds(Vector2(local_x, local_y))):
        # The tile to check is off-limits, count that as a wall
        count_alive += 1
      elif (cellmap[local_x][local_y]):
        count_alive += 1

  return count_alive


func _close_borders():
  # Horizontal borders
  for x in global.MAP_WIDTH:
    tilemap.set_cell(x, -1, 1)
    tilemap.set_cell(x, global.MAP_HEIGHT, 1)
  # Vertical borders
  for y in global.MAP_HEIGHT:
    tilemap.set_cell(-1, y, 1)
    tilemap.set_cell(global.MAP_WIDTH, y, 1)


# Prints the map onto the screen using its tilemap
func _print_map():
  for x in global.MAP_WIDTH:
    for y in global.MAP_HEIGHT:
      tilemap.set_cell(x, y, cellmap[x][y])


func _on_exit_reached():
  _ready()


func _on_Player_spawned(position: Vector2):
  player_spawn_pos = position


func _on_Exit_spawned(position: Vector2):
  exit_spawn_pos = position


func _on_Enemy_spawned(position: Vector2):
  enemy_spawn_pos = position
