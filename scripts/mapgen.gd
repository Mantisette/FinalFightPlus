extends Node2D

const SIMULACIONES = 3

export var PROBABILIDAD_INICIAL := 0.375
export var LIMITE_VIDA = 4
export var LIMITE_MUERTE = 3

var cellmap := []
onready var tilemap := $TileMap
signal preparado

onready var spawn_jugador: Vector2
onready var spawn_salida: Vector2
onready var spawn_enemigo: Vector2


func _ready():
  randomize()
  _generar_matriz()
  _generar_mapa()

  for _x in range(SIMULACIONES):
    _simulacion()
  _cerrar_limites()

  _dibujar_mapa()
  global.cellmap = cellmap

  global.astar_ready()

  emit_signal("preparado")
  
  if !_spawn_preparado():
    return
  var path_jugador = global.astar_find_path(spawn_jugador, spawn_salida)
  var path_enemigo = global.astar_find_path(spawn_enemigo, spawn_jugador)
  if path_jugador == [] or path_enemigo == []:
    _ready()


func _spawn_preparado() -> bool:
  return (spawn_jugador != null and spawn_salida != null and spawn_enemigo != null)


# Debug, para probar el algoritmo
func _unhandled_input(event):
  if event.is_action_pressed("key_f1"):
    _generar_mapa()
    _dibujar_mapa()

  if event.is_action_pressed("key_f2"):
    _simulacion()
    _dibujar_mapa()

  if event.is_action_pressed("key_f3"):
    _ready()


# Crea una matriz 2D
func _generar_matriz():
  for i in global.MAPA_ANCHO:
    cellmap.append([])
    for j in global.MAPA_ALTO:
      cellmap[i].append(0)


# Rellena la matriz 2D con valores aleatorios según la regla inicial
func _generar_mapa():
  for x in range(global.MAPA_ANCHO):
    for y in range(global.MAPA_ALTO):
      if randf() < PROBABILIDAD_INICIAL:
        cellmap[x][y] = 1
      else:
        cellmap[x][y] = 0


# Hace una simulación del juego de la vida con el mapa actual. Sustituye el mapa resultante al terminar
func _simulacion():
  var cellmap_proc = cellmap.duplicate(true)

  for x in global.MAPA_ANCHO:
    for y in global.MAPA_ALTO:
      var casilla = cellmap_proc[x][y]
      var vecinos = _contar_vecinos_vivos(x, y)
      if (cellmap[x][y] == 1):
        # La casilla está viva (es un muro), cambia según las reglas de la muerte
        if (vecinos < LIMITE_MUERTE):
          casilla = 0
        else:
          casilla = 1
      else:
        # La casilla está muerta (es suelo), cambia según las reglas de la vida.
        if (vecinos > LIMITE_VIDA):
          casilla = 1
        else:
          casilla = 0
      cellmap_proc[x][y] = casilla

  cellmap = cellmap_proc


# Devuelve el número de casillas vivas en las casillas adyacentes
func _contar_vecinos_vivos(x: int, y: int) -> int:
  var vivas := 0

  for i in range(-1, 2):
    for j in range(-1, 2):
      var x_ady = x + i
      var y_ady = y + j

      if (i == 0 and j == 0):
        # Esta es nuestra misma casilla
        continue
      elif (global.casilla_fuera_de_limites(Vector2(x_ady, y_ady))):
        # La casilla está fuera del mapa, se cuenta como un muro
        vivas += 1
      elif (cellmap[x_ady][y_ady]):
        vivas += 1

  return vivas


func _cerrar_limites():
  # Límites Horizontales
  for x in global.MAPA_ANCHO:
    tilemap.set_cell(x, -1, 1)
    tilemap.set_cell(x, global.MAPA_ALTO, 1)
  # Límites Verticales
  for y in global.MAPA_ALTO:
    tilemap.set_cell(-1, y, 1)
    tilemap.set_cell(global.MAPA_ANCHO, y, 1)


# Dibuja el mapa usando el tilemap proporcionado
func _dibujar_mapa():
  for x in global.MAPA_ANCHO:
    for y in global.MAPA_ALTO:
      tilemap.set_cell(x, y, cellmap[x][y])


func _on_Jugador_spawn(spawn):
  spawn_jugador = spawn


func _on_Salida_spawn(spawn):
  spawn_salida = spawn


func _on_Enemigo_spawn(spawn):
  spawn_enemigo = spawn


func _on_salida_alcanzada():
  _ready()
