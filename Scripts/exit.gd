extends Area2D


signal exit_reached


func _on_map_ready():
  position = global.tile_to_pixel_center(global.exit_spawn)


func _on_area_entered(area):
  if area is Player:
    emit_signal("exit_reached")
