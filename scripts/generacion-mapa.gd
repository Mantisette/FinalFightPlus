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

export var MAP_WIDTH := 32
export var MAP_HEIGHT := 24
export var INITIAL_LIFE_CHANCE := 0.415
export var BIRTH_LIMIT = 4
export var DEATH_LIMIT = 3

var cellmap := []
var astar = AStar2D.new()
onready var tilemap := $TileMap

#signal map_ready

func _ready():
  randomize()
  _generate_grid()
  _generate_map()
  for _x in range(STEPS): # Shape the og grid into a cave-looking map
    _simulation_step()
  _print_map()
  var player_spawn = _random_spawn()
  var exit_spawn = _random_spawn()

  _pathfind_player_exit(player_spawn, exit_spawn)

#  if !_pathfind_player_to_exit(player_spawn, exit_spawn):
#    _ready()
#  else:
#    Global.player_spawn = self.player_spawn
#    emit_signal("map_ready")
# _flood_fill(player_spawn)




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


# Prints the map onto the screen using the tilemap provided
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


func _pathfind_player_exit(player_spawn: Vector2, exit_spawn: Vector2):
  pass


#func _create_pathfind_points():
#  astar.clear()
#  var used_cell_positions = tilemap.get_used_cell_global_positions()
#  for cell_position in used_cell_positions:
#    astar.add_point(tilemap.get_point(cell_position), cell_position)
#
#  for cell_position in used_cell_positions:
#    _connect_points(cell_position)
#
#
#func _connect_points():
#  var center := get_point
#
#
#func connect_cardinals(point_position) -> void:
#	var center := get_point(point_position)
#	var directions := DIRECTIONS
#
#	if diagonals: 
#		var diagonals_array := [Vector2(1,1), Vector2(1,-1)]	# Only two needed for generation
#		directions += diagonals_array
#
#	for direction in directions:
#		var cardinal_point := get_point(point_position + map_to_world(direction))
#		if cardinal_point != center and astar.has_point(cardinal_point):
#			astar.connect_points(center, cardinal_point, true)
#
#
#




# TODO: flood fill from the player pos
  # if flood fill < half the total tiles:
  # regen map
# TODO: pathfind between the two spawns
# signal that the map is ready















# esto crashea el programa
#func _flood_fill(spawn: Vector2) -> int:
#  var stack = []
#  stack.append(spawn)
#
#  while !stack.empty():
#    var n = stack.pop_back()
#    if (cellmap[n.x][n.y] == 0):
#      for dir in DIRECTIONS:
#        var next_tile = n + dir
#        if (cellmap[next_tile.x][next_tile.y] == 0):
#          stack.append(next_tile)
#
#  print (stack.size)
#  return stack.size
