extends Node2D

onready var audio_stream := $AudioStream

signal spawned
signal exit_reached

var current_volume = global.MIN_VOLUME


func _ready():
  audio_stream.play(0)
  audio_stream.volume_db = current_volume


func _process(_delta):
  if audio_stream.volume_db == current_volume:
    return

  if audio_stream.volume_db < current_volume:
    audio_stream.volume_db += global.VOLUME_STEP
  elif audio_stream.volume_db > current_volume:
    audio_stream.volume_db -= global.VOLUME_STEP


func _on_map_ready():
  var spawn_pos = global.tile_to_pixel_center(global.random_spawn())
  position = spawn_pos
  emit_signal("spawned", spawn_pos)


func _on_ExitArea_entered(area):
  if area is Player:
    emit_signal("exit_reached")


func _on_AudioArea_entered(area):
  if area is Player:
    current_volume = global.MAX_VOLUME


func _on_AudioArea_exited(area):
  if area is Player:
    current_volume = global.MIN_VOLUME
