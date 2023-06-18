extends Node2D

onready var audio_stream := $AudioStream

signal spawn
signal salida_alcanzada

var volumen_actual = global.VOLUMEN_MINIMO


func _ready():
  audio_stream.play(0)
  audio_stream.volume_db = volumen_actual


func _process(_delta):
  if audio_stream.volume_db == volumen_actual:
    return

  if audio_stream.volume_db < volumen_actual:
    audio_stream.volume_db += global.VOLUMEN_CAMBIO
  elif audio_stream.volume_db > volumen_actual:
    audio_stream.volume_db -= global.VOLUMEN_CAMBIO


func _on_Mapgen_preparado():
  var spawn = global.casilla_a_pixeles_centro(global.random_spawn())
  position = spawn
  emit_signal("spawn", spawn)


func _on_AreaSalida_area_entered(area):
  if area is Jugador:
    emit_signal("salida_alcanzada")


func _on_AreaAudio_area_entered(area):
  if area is Jugador:
    volumen_actual = global.VOLUMEN_MAXIMO


func _on_AreaAudio_area_exited(area):
  if area is Jugador:
    volumen_actual = global.VOLUMEN_MINIMO
