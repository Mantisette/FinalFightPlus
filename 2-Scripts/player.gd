class_name Player
extends Area2D

const MAX_HEALTH = 5
const MIN_HEALTH = 0
var health: int

onready var raycasts = {
  "RayCenter": get_node("RayCenter"),
  "RayLeft": get_node("RayLeft"),
  "RayRight": get_node("RayRight"),
}

var movement = {
  "move_N":  Vector2.UP,
  "move_NE": Vector2.UP + Vector2.RIGHT,
  "move_E":  Vector2.RIGHT,
  "move_SE": Vector2.DOWN + Vector2.RIGHT,
  "move_S":  Vector2.DOWN,
  "move_SW": Vector2.DOWN + Vector2.LEFT,
  "move_W":  Vector2.LEFT,
  "move_NW": Vector2.UP + Vector2.LEFT,
}

func _ready():
  pass

func _unhandled_input(event):
  for dir in movement.keys():
    if event.is_action_pressed(dir):
      move(dir)

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


func _on_map_ready():
  position = global.tile_to_pixel_center(global.player_spawn)


func _on_exit_reached():
  print("i got a point!")
