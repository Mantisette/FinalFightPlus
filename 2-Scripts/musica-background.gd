extends Node2D

const lista_calma = [
  "res://4-Musica/calm-1-larnii.mp3",
  "res://4-Musica/calm-2-larnii.mp3",
  "res://4-Musica/calm-3-larnii.mp3",
  "res://4-Musica/calm-4-larnii.mp3",
  "res://4-Musica/calm-5-larnii.mp3",
  "res://4-Musica/calm-6-larnii.mp3",
  "res://4-Musica/calm-7-larnii.mp3",
  "res://4-Musica/calm-8-CoQ.mp3"
 ]

const lista_combate = [
  "res://4-Musica/combat-1-larnii.mp3",
  "res://4-Musica/combat-2-larnii.mp3",
  "res://4-Musica/combat-3-larnii.mp3",
  "res://4-Musica/combat-4-larnii.mp3"
 ]

onready var animator = $Animator
onready var stream_calma = $Animator/StreamCalma
onready var stream_combate = $Animator/StreamCombate


func _ready():
  randomize()
  stream_calma.stream = _cancion_aleatoria(false)
  stream_combate.stream = _cancion_aleatoria(true)
  stream_calma.volume_db = global.VOLUMEN_MAXIMO
  stream_combate.volume_db = global.VOLUMEN_MINIMO
  stream_calma.play()
  stream_combate.play()


func _cancion_aleatoria(combate: bool):
  # Elegir cancion
  var path: String
  if !combate:
    var size = lista_calma.size()
    path = lista_calma[randi() % size]
  else:
    var size = lista_combate.size()
    path = lista_combate[randi() % size]

  # Cargar el recurso
  if File.new().file_exists(path):
    var res = load(path)
    res.set_loop(true)
    return res


func _on_musica_calma():
  animator.play("crossfade-calma")


func _on_musica_combate():
  animator.play("crossfade-combate")


func _on_Mapgen_preparado(): # Cada vez que se cambia de nivel, se randomiza la música
  # Si aún no se han instanciado los streams, no se puede hacer nada
  if (!stream_calma): return
  if (!stream_combate): return

  stream_calma.stream = _cancion_aleatoria(false)
  stream_calma.play()
  stream_combate.stream = _cancion_aleatoria(true)
  stream_combate.play()
