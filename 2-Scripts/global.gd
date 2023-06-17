extends Node

const TILE_SIZE := 16
const HALF_TILE := TILE_SIZE / 2

const MAX_VOLUME := -0.0
const MIN_VOLUME := -80.0
const VOLUME_STEP := 5.0

var MAP_WIDTH: int
var MAP_HEIGHT: int
var map: Array
var player_turn := true


func tile_to_pixel(tile: Vector2) -> Vector2:
  return Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)


func tile_to_pixel_center(tile: Vector2) -> Vector2:
  tile = tile_to_pixel(tile)
  return Vector2(tile.x + HALF_TILE, tile.y + HALF_TILE)


# Selects a random spawn position for a thing
func random_spawn() -> Vector2:
  var spawn_x: int
  var spawn_y: int
  var is_tile_available = 1 # wall

  while is_tile_available:
    spawn_x = randi() % MAP_WIDTH
    spawn_y = randi() % MAP_HEIGHT
    is_tile_available = map[spawn_x][spawn_y]

  var spawn = Vector2(spawn_x, spawn_y)
  return spawn
