extends Area2D


func _on_map_ready():
  position = global.exit_spawn * global.TILE_SIZE
  position += Vector2(global.HALF_TILE, global.HALF_TILE)
