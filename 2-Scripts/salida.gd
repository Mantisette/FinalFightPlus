extends Node2D

onready var audio_stream := $AudioStream

signal spawn
signal salida_alcanzada

var current_volume = global.VOLUMEN_MINIMO


func _ready():
  audio_stream.play(0)
  audio_stream.volume_db = current_volume


func _process(_delta):
  if audio_stream.volume_db == current_volume:
    return

  if audio_stream.volume_db < current_volume:
    audio_stream.volume_db += global.VOLUMEN_CAMBIO
  elif audio_stream.volume_db > current_volume:
    audio_stream.volume_db -= global.VOLUMEN_CAMBIO


func _on_map_ready():
  var spawn_pos = global.casilla_a_pixeles_centro(global.random_spawn())
  position = spawn_pos
  emit_signal("spawn", spawn_pos)


func _on_ExitArea_entered(area):
  if area is Jugador:
    emit_signal("salida_alcanzada")


func _on_AudioArea_entered(area):
  if area is Jugador:
    current_volume = global.VOLUMEN_MAXIMO


func _on_AudioArea_exited(area):
  if area is Jugador:
    current_volume = global.VOLUMEN_MINIMO


func _on_Mapgen_preparado():
  pass # Replace with function body.
