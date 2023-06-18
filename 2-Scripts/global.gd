extends Node

const MAPA_ANCHO := 48
const MAPA_ALTO := 36
const TAMANO_CASILLA := 16
const MEDIA_CASILLA := TAMANO_CASILLA / 2

const VOLUMEN_MAXIMO := -0.0
const VOLUMEN_MINIMO := -80.0
const VOLUMEN_CAMBIO := 5.0

var cellmap: Array


# Conversiones entre pixeles de la pantalla y posiciones en la matriz del mapa
func casilla_a_pixeles(casilla: Vector2) -> Vector2:
  return Vector2(casilla.x * TAMANO_CASILLA, casilla.y * TAMANO_CASILLA)


func casilla_a_pixeles_centro(casilla: Vector2) -> Vector2:
  casilla = casilla_a_pixeles(casilla)
  return Vector2(casilla.x + MEDIA_CASILLA, casilla.y + MEDIA_CASILLA)


func pixeles_a_casilla(coordenadas: Vector2) -> Vector2:
  return Vector2(int(coordenadas.x / TAMANO_CASILLA), int(coordenadas.y / TAMANO_CASILLA))


# Devuelve un punto de spawn aleatorio en una casilla de suelo
func random_spawn() -> Vector2:
  var spawn_x: int
  var spawn_y: int
  var casilla_disponible = 1 # Pared

  while casilla_disponible:
    spawn_x = randi() % MAPA_ANCHO
    spawn_y = randi() % MAPA_ALTO
    casilla_disponible = cellmap[spawn_x][spawn_y]

  var spawn = Vector2(spawn_x, spawn_y)
  return spawn


# Algorito AStar
onready var astar = AStar.new()

var inicio_camino = Vector2() setget _set_path_start_position
var fin_camino = Vector2() setget _set_path_end_position

var camino = []


func astar_ready():
  astar.clear()
  var casillas_atravesables = _astar_agregar_casillas_atravesables()
  _astar_conectar_casillas(casillas_atravesables)


# Recorre todo el mapa y añade a la matriz astar nuevos puntos en las casillas atravesables
func _astar_agregar_casillas_atravesables():
  var lista_puntos = []
  for y in range(MAPA_ALTO):
    for x in range(MAPA_ANCHO):
      if cellmap[x][y]: # Si la casilla es un muro, no se puede atravesar
        continue
      var punto = Vector2(x, y)
      lista_puntos.append(punto)

      # La clase AStar hace referencia a sus puntos con índices, por lo tanto,
      # necesitamos una forma de traducir las coordenadas a un índice y viceversa.
      # Así cada casilla tiene un id propio, del que se pueden deducir las coordenadas
      var id_punto = _astar_calcular_id_punto(punto)
      
      # Como AStar trabaja tanto con 2D como con 3D, hay que traducir los puntos
      # a Vector3. Esto solo ocurre aquí.
      astar.add_point(id_punto, Vector3(punto.x, punto.y, 0.0))
  return lista_puntos


# Con los puntos añadidos, toca conectar cada punto con su vecino para crear caminos posibles
func _astar_conectar_casillas(lista_puntos):
  for punto in lista_puntos:
    var id_punto = _astar_calcular_id_punto(punto)

    # Para cada casilla, conectamos con las de arriba, abajo, izquierda y derecha
    var puntos_relativos = PoolVector2Array([
      Vector2(punto.x + 1, punto.y),
      Vector2(punto.x - 1, punto.y),
      Vector2(punto.x, punto.y + 1),
      Vector2(punto.x, punto.y - 1)])

    for relativo in puntos_relativos:
      var id_relativo = _astar_calcular_id_punto(relativo)
      if casilla_fuera_de_limites(relativo):
        continue
      if not astar.has_point(id_relativo):
        continue
      astar.connect_points(id_punto, id_relativo, false)


func casilla_fuera_de_limites(casilla: Vector2) -> bool:
  return (
      casilla.x < 0 or casilla.x >= global.MAPA_ANCHO or
      casilla.y < 0 or casilla.y >= global.MAPA_ALTO
    )

func _astar_calcular_id_punto(punto):
  return punto.x + MAPA_ANCHO * punto.y


func astar_find_path(inicio, fin):
  self.inicio_camino = inicio
  self.fin_camino = fin
  _calcular_camino()
  var camino_pixeles = []
  for punto in camino:
    var punto_pixeles = casilla_a_pixeles_centro(Vector2(punto.x, punto.y))
    camino_pixeles.append(punto_pixeles)
  return camino_pixeles


func _calcular_camino():
  var id_inicio = _astar_calcular_id_punto(inicio_camino)
  var id_fin = _astar_calcular_id_punto(fin_camino)
  camino = astar.get_point_path(id_inicio, id_fin)


# Setters para los puntos de inicio y fin
func _set_path_start_position(punto):
  punto = pixeles_a_casilla(punto)
  if cellmap[punto.x][punto.y] == 1:
    return
  if casilla_fuera_de_limites(punto):
    return

  inicio_camino = punto
  if fin_camino and fin_camino != inicio_camino:
    _calcular_camino()


func _set_path_end_position(punto):
  punto = pixeles_a_casilla(punto)
  if cellmap[punto.x][punto.y] == 1:
    return
  if casilla_fuera_de_limites(punto):
    return

  fin_camino = punto
  if inicio_camino != punto:
    _calcular_camino()
