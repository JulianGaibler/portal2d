extends Node2D

enum Direction { UP, DOWN }

const audio_lift_arrive = preload("res://sounds/empty.wav")
const audio_lift_depart = preload("res://sounds/empty.wav")
const audio_door_open = preload("res://sounds/empty.wav")
const audio_door_close = preload("res://sounds/empty.wav")

onready var animation_player = $AnimationPlayer
onready var elevator = $Elevator
onready var enter_area = $EnterArea
onready var elevator_area = $ElevatorArea
onready var ceiling_light = $CeilingLight
onready var door_audio = $DoorAudio
onready var chime_audio = $ChimeAudio
onready var lift_audio = $Elevator/LiftAudio

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
        lift_audio.set_stream(audio_lift_arrive)
        lift_audio.play(3.0)
        enter_area.queue_free()
        match exit_direction:
            Direction.UP: animation_player.play("up-arrive")
            Direction.DOWN: animation_player.play("down-arrive")
        yield(get_tree().create_timer(2.0), "timeout")
        door_audio.set_stream(audio_door_open)
        door_audio.play()
        yield(get_tree().create_timer(0.2), "timeout")
        elevator.open()
        yield(get_tree().create_timer(0.5), "timeout")
        chime_audio.play()

func enters_elevator(body):
    if body.is_in_group("player"):
        elevator_area.queue_free()
        elevator.close()
        door_audio.set_stream(audio_door_close)
        door_audio.play()
        match exit_direction:
            Direction.UP: animation_player.play("up-leave")
            Direction.DOWN: animation_player.play("down-leave")
        yield(get_tree().create_timer(1.0), "timeout")
        lift_audio.set_stream(audio_lift_depart)
        lift_audio.play()
        yield(get_tree().create_timer(1.5), "timeout")
        Game.goto_scene_fade(load_level)
