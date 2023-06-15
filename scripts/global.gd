extends Node

const TILE_SIZE := 16
const HALF_TILE := TILE_SIZE / 2

var map: Array
var player_spawn: Vector2
var exit_spawn: Vector2

func tile_to_pixel(tile: Vector2) -> Vector2:
  return Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)


func tile_to_pixel_center(tile: Vector2) -> Vector2:
  tile = tile_to_pixel(tile)
  return Vector2(tile.x + HALF_TILE, tile.y + HALF_TILE)
