extends Node2D

onready var musica_calma := $MusicaCalma
onready var musica_combate := $MusicaCombate

func _ready():
  musica_calma.volume_db = 0
  musica_combate.volume_db = -80
