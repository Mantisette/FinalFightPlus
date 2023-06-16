extends Node2D

const movement = {
  "move_N":  Vector2.UP,
  "move_NE": Vector2.UP + Vector2.RIGHT,
  "move_E":  Vector2.RIGHT,
  "move_SE": Vector2.DOWN + Vector2.RIGHT,
  "move_S":  Vector2.DOWN,
  "move_SW": Vector2.DOWN + Vector2.LEFT,
  "move_W":  Vector2.LEFT,
  "move_NW": Vector2.UP + Vector2.LEFT,
}

onready var raycasts = {
  "RayCenter": get_node("RayCenter"),
  "RayLeft": get_node("RayLeft"),
  "RayRight": get_node("RayRight"),
}

var player_detected := false

signal combat_music
signal calm_music
# signal attack_player

func _process(_delta):
  if (global.player_turn):
    return
  if (!player_detected):
    return
  print("player detected")


func move(dir):
  var destination = global.tile_to_pixel(movement[dir])
  var collisions = 0

  for key in raycasts:
    var ray = raycasts[key]
    ray.cast_to = destination
    ray.force_raycast_update()
    if ray.is_colliding():
      collisions += 1

  if collisions < 3:
    position += destination


func _on_DetectionArea_entered(area):
  if area is Player:
    player_detected = true
    emit_signal("combat_music")


func _on_DetectionArea_exited(area):
  if area is Player:
    player_detected = false
    emit_signal("calm_music")
