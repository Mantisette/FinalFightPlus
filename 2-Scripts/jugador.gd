class_name Jugador
extends Area2D

onready var raycasts = {
  "RayCenter": get_node("RayCenter"),
  "RayLeft": get_node("RayLeft"),
  "RayRight": get_node("RayRight"),
}

const MOVIMIENTOS = {
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
  for direccion in MOVIMIENTOS.keys():
    if event.is_action_pressed(direccion):
      mover_a(direccion)

  if event.is_action_pressed("key_f4"):
    var camara = $Camara
    if camara.zoom == Vector2(0.35, 0.35):
      camara.zoom = Vector2(1, 1)
    else:
      camara.zoom = Vector2(0.35, 0.35)

func mover_a(direccion):
  var destino = global.casilla_a_pixeles(MOVIMIENTOS[direccion])
  var colisiones = 0

  for key in raycasts:
    var ray = raycasts[key]
    ray.cast_to = destino
    ray.force_raycast_update()
    if ray.is_colliding():
      colisiones += 1

  if colisiones < 3:
    position += destino


func _on_Mapgen_preparado():
  var spawn = global.casilla_a_pixeles_centro(global.random_spawn())
  position = spawn
  emit_signal("spawn", spawn)


func _on_Salida_salida_alcanzada():
  puntos += 1
