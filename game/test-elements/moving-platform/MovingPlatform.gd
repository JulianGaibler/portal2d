extends Node2D

# NodePaths are just things that are already in the scene. You can safely assume that they all have the global_position property.
# You can add nodes by placing the MovingPlatform Scene in the world and add Nodes to the array via the inspector.
# Also I suggest you have a look at the "Tween" Node for moving the platform!
#
# Don't worry, this will probably take less than an hour. Thanks for doing it!

export(bool) var is_active = false
export(bool) var autostart = true
export(bool) var loop = false
export (bool) var move_to_start = false
export (int) var duration = 3
export var wait_duration = 1
export (NodePath) var positions_points = NodePath()
var positions = []
var start_position
onready var TweenNode = get_node("Tween")
onready var DurationTimer = get_node("Timer")

var waypoint_index = 1

func _ready():
    start_position = position
    if autostart:
        start()

func start():
    is_active = true
    var waypoints = get_node(positions_points).get_children()
    positions = []    
    for i in range(len(waypoints) + 1):
        if i == 0:
            positions.append(position)
        else:
            positions.append(waypoints[i-1].position)
    if waypoint_index == 1:
        next_move(positions)
    DurationTimer.set_wait_time(duration)
    DurationTimer.connect("timeout",self, "_on_Timer_timeout", [positions])
    DurationTimer.start()
    

func next_move(positions):
    if (waypoint_index == len(positions)):
        positions.invert()
        waypoint_index = 0
        if loop:
            is_active = true
        else:
            stop()
            return
    move(position, positions[waypoint_index])
    waypoint_index += 1
    
func stop():
    if move_to_start:
        move_to_start()
    TweenNode.stop(TweenNode)
    DurationTimer.stop()
    is_active = false

func move_to_start():
    TweenNode.interpolate_property(self, "position", position, start_position, duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    TweenNode.start()

func move_to_end():
    TweenNode.interpolate_property(self, "position", position, positions[len(positions)-1], duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    TweenNode.start()    

func move(from, to):
    TweenNode.interpolate_property(self, "position", from, to, duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    TweenNode.start()


func toggle():
    if not is_active:
        activate()
    else:
        deactivate()
        
func deactivate():
    stop()

func activate():
    start()

func _on_Timer_timeout(positions):
    next_move(positions)
