extends Node2D

const MAX_VOLUME := -20.0
const MIN_VOLUME := -80.0
const VOLUME_STEP := 2.0
onready var audio_stream := $AudioStream
signal exit_reached

var current_volume = MIN_VOLUME


func _ready():
  audio_stream.play(0)
  audio_stream.volume_db = -80.0


func _process(delta):
  if audio_stream.volume_db < current_volume:
    audio_stream.volume_db += VOLUME_STEP
  elif audio_stream.volume_db > current_volume:
    audio_stream.volume_db -= VOLUME_STEP


func _on_map_ready():
  position = global.tile_to_pixel_center(global.exit_spawn)


func _on_ExitArea_entered(area):
  if area is Player:
    emit_signal("exit_reached")


func _on_AudioArea_entered(area):
  if area is Player:
    current_volume = MAX_VOLUME


func _on_AudioArea_exited(area):
  if area is Player:
    current_volume = MIN_VOLUME
