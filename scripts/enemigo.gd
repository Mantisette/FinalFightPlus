extends Node2D


func _on_AreaMusica_area_entered(area):
  # if area.rid == 1307:
  print(area)
  get_tree().call_group("MusicaCombate", "cambiar_musica_combate")


func _on_AreaMusica_area_exited(area):
  print(area)
  get_tree().call_group("MusicaCombate", "cambiar_musica_calma")


func _on_AreaDamage_area_entered(area):
  print(area)
  get_tree().call_group("Combate", "jugador_damage")
