extends Node2D

onready var raycasts = {
  "RayCenter": get_node("RayCenter"),
  "RayLeft": get_node("RayLeft"),
  "RayRight": get_node("RayRight"),
}

signal spawn
signal musica_calma
signal musica_combate


func _on_Mapgen_preparado():
  var spawn = global.casilla_a_pixeles_centro(global.random_spawn())
  position = spawn
  emit_signal("spawn", spawn)


func _on_AreaDeteccion_area_entered(area):
  if area is Jugador:
    emit_signal("musica_combate")


func _on_AreaDeteccion_area_exited(area):
  if area is Jugador:
    emit_signal("musica_calma")
