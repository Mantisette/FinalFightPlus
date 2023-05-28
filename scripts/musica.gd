extends Node2D

const MIN_VOLUME = -40
const MAX_VOLUME = -10
const VOLUME_STEP = 2

onready var musica_calma := $MusicaCalma
onready var musica_combate := $MusicaCombate

export var combate := false

func _ready():
  musica_combate.volume_db = MIN_VOLUME


func _process(delta):
  if !combate:
    cambiar_volumen(musica_calma, MAX_VOLUME, true)
    cambiar_volumen(musica_combate, MIN_VOLUME, false)
  else:
    cambiar_volumen(musica_calma, MIN_VOLUME, false)
    cambiar_volumen(musica_combate, MAX_VOLUME, true)


func cambiar_volumen(pista, objetivo, aumentar = false):
  var volumen = pista.volume_db
  if aumentar and volumen < objetivo:
    pista.volume_db += VOLUME_STEP
  elif !aumentar and volumen > objetivo:
    pista.volume_db -= VOLUME_STEP


func cambiar_musica_combate():
  combate = true


func cambiar_musica_calma():
  combate = false
