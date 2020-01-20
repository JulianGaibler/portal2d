extends Node2D

enum Direction { ABOVE, BELOW }

onready var animation_player = $AnimationPlayer
onready var elevator = $Elevator
onready var leave_area = $LeaveArea
onready var ceiling_light = $CeilingLight
onready var door_audio = $DoorAudio
onready var chime_audio = $ChimeAudio
onready var lift_audio = $Elevator/LiftAudio

export(Direction) var arrives_from = Direction.ABOVE
export (NodePath) var teleport_to_elevator = null

func _ready():
    ceiling_light.enabled = true
    
    match arrives_from:
        Direction.ABOVE: animation_player.play("down-arrive")
        Direction.BELOW: animation_player.play("up-arrive")
    lift_audio.play(0.5)
    
    if teleport_to_elevator != null: call_deferred("_teleport")
    
    yield(get_tree().create_timer(4.4), "timeout")
    door_audio.play()
    elevator.open()
    leave_area.connect("body_entered", self, "leaves_room")
    yield(get_tree().create_timer(0.5), "timeout")
    chime_audio.play()

func _teleport():
    yield(get_tree(), "physics_frame")
    yield(get_tree(), "physics_frame")
    yield(get_tree(), "physics_frame")
    var player = get_node(teleport_to_elevator)
    player.global_position = $Elevator/Position2D.global_position
    match arrives_from:
        Direction.ABOVE: player.linear_velocity += Vector2.DOWN * 1000
        Direction.BELOW: player.linear_velocity += Vector2.UP * 1000

func leaves_room(body):
    if body.is_in_group("player"):
        ceiling_light.enabled = false
        leave_area.queue_free()
