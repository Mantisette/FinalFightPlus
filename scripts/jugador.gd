extends Area2D

onready var raycast = $RayCast2D

var movement = {
  "move_N": Vector2.UP,
  "move_NE": Vector2.UP + Vector2.RIGHT,
  "move_E": Vector2.RIGHT,
  "move_SE": Vector2.DOWN + Vector2.RIGHT,
  "move_S": Vector2.DOWN,
  "move_SW": Vector2.DOWN + Vector2.LEFT,
  "move_W": Vector2.LEFT,
  "move_NW": Vector2.UP + Vector2.LEFT,
}

func _ready():
  #TODO: spawn the player in a ground tile
  position = Global.first_floor * Global.TILE_SIZE
  position += Vector2(Global.TILE_SIZE / 2, Global.TILE_SIZE / 2)

func _unhandled_input(event):
  for dir in movement.keys():
    if event.is_action_pressed(dir):
      move(dir)

func move(dir):
  raycast.cast_to = movement[dir] * Global.TILE_SIZE
  raycast.force_raycast_update()
  if !raycast.is_colliding():
    position += movement[dir] * Global.TILE_SIZE
