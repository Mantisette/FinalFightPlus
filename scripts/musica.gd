extends Node2D

const MIN_VOLUME = -80
const MAX_VOLUME = 0

onready var musica_calma := $MusicaCalma
onready var musica_combate := $MusicaCombate


func _ready():
  musica_calma.volume_db = MAX_VOLUME
  musica_combate.volume_db = MIN_VOLUME


func cambiar_musica_combate():
  musica_calma.volume_db = MIN_VOLUME
  musica_combate.volume_db = MAX_VOLUME


func cambiar_musica_calma():
  musica_calma.volume_db = MAX_VOLUME
  musica_combate.volume_db = MIN_VOLUME
