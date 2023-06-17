extends Node

const MAP_WIDTH := 48
const MAP_HEIGHT := 36
const TILE_SIZE := 16
const HALF_TILE := TILE_SIZE / 2

const MAX_VOLUME := -0.0
const MIN_VOLUME := -80.0
const VOLUME_STEP := 5.0

var cellmap: Array
var player_turn := true


func tile_to_pixel(tile: Vector2) -> Vector2:
  return Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)


func tile_to_pixel_center(tile: Vector2) -> Vector2:
  tile = tile_to_pixel(tile)
  return Vector2(tile.x + HALF_TILE, tile.y + HALF_TILE)


func pixel_to_tile(coords: Vector2) -> Vector2:
  return Vector2(int(coords.x / TILE_SIZE), int(coords.y / TILE_SIZE))


func pixel_to_tile_center(coords: Vector2) -> Vector2:
  coords = pixel_to_tile(coords)
  return Vector2(coords.x - HALF_TILE, coords.y - HALF_TILE)

# Selects a random spawn position for a thing
func random_spawn() -> Vector2:
  var spawn_x: int
  var spawn_y: int
  var is_tile_available = 1 # wall

  while is_tile_available:
    spawn_x = randi() % MAP_WIDTH
    spawn_y = randi() % MAP_HEIGHT
    is_tile_available = cellmap[spawn_x][spawn_y]

  var spawn = Vector2(spawn_x, spawn_y)
  return spawn











# astar things

onready var astar_node = AStar.new()

# The path start and end variables use setter methods
# You can find them at the bottom of the script
var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []


func astar_ready():
  astar_node.clear()
  var walkable_cells_list = astar_add_walkable_cells()
  astar_connect_walkable_cells(walkable_cells_list)


# Click and Shift force the start and end position of the path to update
# and the node to redraw everything
#func _input(event):
#	if event.is_action_pressed('click') and Input.is_key_pressed(KEY_SHIFT):
#		# To call the setter method from this script we have to use the explicit self.
#		self.path_start_position = world_to_map(get_global_mouse_position())
#	elif event.is_action_pressed('click'):
#		self.path_end_position = world_to_map(get_global_mouse_position())


# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells():
  var points_array = []
  for y in range(MAP_HEIGHT):
    for x in range(MAP_WIDTH):
      if cellmap[x][y]:
        continue
      var point = Vector2(x, y)
      points_array.append(point)
      # The AStar class references points with indices
      # Using a function to calculate the index from a point's coordinates
      # ensures we always get the same index with the same input point
      var point_index = astar_calculate_point_index(point)
      # AStar works for both 2d and 3d, so we have to convert the point
      # coordinates from and to Vector3s
      astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
  return points_array


# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
func astar_connect_walkable_cells(points_array):
  for point in points_array:
    var point_index = astar_calculate_point_index(point)
    # For every cell in the map, we check the one to the top, right.
    # left and bottom of it. If it's in the map and not an obstalce,
    # We connect the current point with it
    var points_relative = PoolVector2Array([
      Vector2(point.x + 1, point.y),
      Vector2(point.x - 1, point.y),
      Vector2(point.x, point.y + 1),
      Vector2(point.x, point.y - 1)])
    for point_relative in points_relative:
      var point_relative_index = astar_calculate_point_index(point_relative)

      if is_tile_off_bounds(point_relative):
        continue
      if not astar_node.has_point(point_relative_index):
        continue
      # Note the 3rd argument. It tells the astar_node that we want the
      # connection to be bilateral: from point A to B and B to A
      # If you set this value to false, it becomes a one-way path
      # As we loop through all points we can set it to false
      astar_node.connect_points(point_index, point_relative_index, false)


func is_tile_off_bounds(tile: Vector2) -> bool:
  return (
      tile.x < 0 or tile.x >= global.MAP_WIDTH or
      tile.y < 0 or tile.y >= global.MAP_HEIGHT
    )

func astar_calculate_point_index(point):
  return point.x + MAP_WIDTH * point.y


func astar_find_path(start, end):
  self.path_start_position = start # world_to_map(world_start)
  self.path_end_position = end # world_to_map(world_end)
  _recalculate_path()
  var path_world = []
  for point in _point_path:
    var point_world = tile_to_pixel_center(Vector2(point.x, point.y))
    path_world.append(point_world)
  return path_world


func _recalculate_path():
  astar_clear_previous_path_drawing()
  var start_point_index = astar_calculate_point_index(path_start_position)
  var end_point_index = astar_calculate_point_index(path_end_position)
  # This method gives us an array of points. Note you need the start and end
  # points' indices as input
  _point_path = astar_node.get_point_path(start_point_index, end_point_index)


func astar_clear_previous_path_drawing():
  if not _point_path:
    return
  var point_start = _point_path[0]
  var point_end = _point_path[len(_point_path) - 1]


func _draw():
  if not _point_path:
    return
  var point_start = _point_path[0]
  var point_end = _point_path[len(_point_path) - 1]

  var last_point = tile_to_pixel_center(point_start)
  for index in range(1, len(_point_path)):
    var current_point = tile_to_pixel_center(Vector2(_point_path[index].x, _point_path[index].y))
    last_point = current_point


# Setters for the start and end path values.
func _set_path_start_position(value):
  value = pixel_to_tile(value)
  if cellmap[value.x][value.y] == 1:
    return
  if is_tile_off_bounds(value):
    return

  path_start_position = value
  if path_end_position and path_end_position != path_start_position:
    _recalculate_path()


func _set_path_end_position(value):
  value = pixel_to_tile(value)
  if cellmap[value.x][value.y] == 1:
    return
  if is_tile_off_bounds(value):
    return

  path_end_position = value
  if path_start_position != value:
    _recalculate_path()
