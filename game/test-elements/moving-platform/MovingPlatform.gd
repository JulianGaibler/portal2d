extends Node2D

onready var tween = get_node("Tween")
onready var timer = get_node("Timer")

export(bool) var autostart = false
export(bool) var loop = false
export(float) var duration = 3
export(float) var wait_duration = 1
export(NodePath) onready var line_path
export(int) var start_index = 0

var waypoint_index = 0
var line

func _ready():
    line = get_node(line_path)
    waypoint_index = start_index
    global_position = line.to_global(line.points[waypoint_index])
    timer.set_wait_time(duration + wait_duration)
    if autostart: start()

func start():
    stop()
    print("connect")
    timer.connect("timeout", self, "_pause_ended")
    waypoint_index = fmod(waypoint_index + 1, len(line.points))
    call_deferred("move_to_waypoint")

func stop():
    print("stop")
    timer.disconnect("timeout", self, "_pause_ended")
    tween.stop_all()
    timer.stop()

func go_to_last():
    stop()
    waypoint_index = len(line.points) - 1
    move_to_waypoint()

func go_to_first():
    stop()
    waypoint_index = 0
    move_to_waypoint()
    

func move_to_waypoint():
    print("a : ", waypoint_index)
    tween.interpolate_property(self, "global_position", global_position, line.to_global(line.points[waypoint_index]), duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    timer.start()

func _pause_ended():
    print("ended2")
    waypoint_index = fmod(waypoint_index + 1, len(line.points))
    if waypoint_index != 0 or loop: move_to_waypoint()
