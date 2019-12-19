extends Node2D

enum Direction { UP, DOWN }

onready var animation_player = $AnimationPlayer
onready var elevator = $Elevator
onready var enter_area = $EnterArea
onready var elevator_area = $ElevatorArea
onready var ceiling_light = $CeilingLight

export(Direction) var exit_direction = Direction.DOWN
export (String, FILE) var load_level = null

func _ready():
    ceiling_light.enabled = false
    
    match exit_direction:
        Direction.UP: animation_player.play("up-pre-arrive")
        Direction.DOWN: animation_player.play("down-pre-arrive")
    
    enter_area.connect("body_entered", self, "enters_room")
    elevator_area.connect("body_entered", self, "enters_elevator")

func enters_room(body):
    if body.is_in_group("player"):
        ceiling_light.enabled = true
        enter_area.queue_free()
        match exit_direction:
            Direction.UP: animation_player.play("up-arrive")
            Direction.DOWN: animation_player.play("down-arrive")
        yield(get_tree().create_timer(2.4), "timeout")
        elevator.open()

func enters_elevator(body):
    if body.is_in_group("player"):
        elevator_area.queue_free()
        elevator.close()
        match exit_direction:
            Direction.UP: animation_player.play("up-leave")
            Direction.DOWN: animation_player.play("down-leave")
        yield(get_tree().create_timer(2.5), "timeout")
        Game.goto_scene_fade(load_level)
