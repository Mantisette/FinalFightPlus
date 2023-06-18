extends Node2D

const calm_songlist = [
  "res://4-Music/calm-1-larnii.mp3",
  "res://4-Music/calm-2-larnii.mp3",
  "res://4-Music/calm-3-larnii.mp3",
  "res://4-Music/calm-4-larnii.mp3",
  "res://4-Music/calm-5-larnii.mp3",
  "res://4-Music/calm-6-larnii.mp3",
  "res://4-Music/calm-7-larnii.mp3",
  "res://4-Music/calm-8-CoQ.mp3"
 ]

const combat_songlist = [
  "res://4-Music/combat-1-larnii.mp3",
  "res://4-Music/combat-2-larnii.mp3",
  "res://4-Music/combat-3-larnii.mp3",
  "res://4-Music/combat-4-larnii.mp3"
 ]

onready var animator = $Animator
onready var calm_node = $Animator/StreamCalma
onready var combat_node = $Animator/StreamCombate

var calm_volume = 0
var combat_volume = global.VOLUMEN_MINIMO


func _ready():
  randomize()
  calm_node.stream = _select_random_song(false)
  combat_node.stream = _select_random_song(true)
  calm_node.volume_db = calm_volume
  combat_node.volume_db = combat_volume
  calm_node.play()
  combat_node.play()


func _select_random_song(type: bool):
  # Choose a song
  var path: String
  if !type:
    var size = calm_songlist.size()
    path = calm_songlist[randi() % size]
  else:
    var size = combat_songlist.size()
    path = combat_songlist[randi() % size]

  # Load it to the ASP
  if File.new().file_exists(path):
    var res = load(path)
    res.set_loop(true)
    return res


func _on_musica_calma():
  animator.play("crossfade-calma")


func _on_musica_combate():
  animator.play("crossfade-combate")


func _on_Mapgen_preparado():
  # If the ASPs haven't been created, return
  if (!calm_node): return
  if (!combat_node): return

  calm_node.stream = _select_random_song(false)
  calm_node.play()
  combat_node.stream = _select_random_song(true)
  combat_node.play()
