class_name Jugador
extends Area2D

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

signal spawn
var puntos := 0


func _unhandled_input(event):
  for dir in movement.keys():
    if event.is_action_pressed(dir):
      move(dir)

func move(dir):
  var destination = global.casilla_a_pixeles(movement[dir])
  var collisions = 0

  for key in raycasts:
    var ray = raycasts[key]
    ray.cast_to = destination
    ray.force_raycast_update()
    if ray.is_colliding():
      collisions += 1

  if collisions < 3:
    position += destination


func _on_Mapgen_preparado():
  var spawn_pos = global.casilla_a_pixeles_centro(global.random_spawn())
  position = spawn_pos
  emit_signal("spawn", spawn_pos)


func _on_Salida_salida_alcanzada():
  puntos += 1
