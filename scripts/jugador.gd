extends Area2D

const MAX_HEALTH = 5
const MIN_HEALTH = 0
var health: int

onready var raycast = $RayCast2D
onready var label = $Label

var movement = {
  "move_N":  Vector2.UP,
  "move_NE": Vector2.UP + Vector2.RIGHT,
  "move_E":  Vector2.RIGHT,
  "move_SE": Vector2.DOWN + Vector2.RIGHT,
  "move_S":  Vector2.DOWN,
  "move_SW": Vector2.DOWN + Vector2.LEFT,
  "move_W":  Vector2.LEFT,
  "move_NW": Vector2.UP + Vector2.LEFT,
}

func _ready():
  health = MAX_HEALTH
  label.text = str(health)

func _unhandled_input(event):
  for dir in movement.keys():
    if event.is_action_pressed(dir):
      move(dir)

func move(dir):
  raycast.cast_to = movement[dir] * Global.TILE_SIZE
  raycast.force_raycast_update()
  if !raycast.is_colliding():
    position += movement[dir] * Global.TILE_SIZE

func jugador_damage():
  self.health -= 1
  label.text = str(health)


func _on_map_ready():
  position = Global.player_spawn * Global.TILE_SIZE
  position += Vector2(Global.TILE_SIZE / 2, Global.TILE_SIZE / 2)
