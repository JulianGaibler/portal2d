extends Node2D

# NodePaths are just things that are already in the scene. You can safely assume that they all have the global_position property.
# You can add nodes by placing the MovingPlatform Scene in the world and add Nodes to the array via the inspector.
# Also I suggest you have a look at the "Tween" Node for moving the platform!
#
# Don't worry, this will probably take less than an hour. Thanks for doing it!

export(bool) var is_active = false
export(bool) var loop = false
export var duration = 3
export var wait_duration = 1
export (NodePath) var positions = NodePath()
onready var TweenNode = get_node("Tween")
onready var DurationTimer = get_node("Timer")

var DURATION = duration
var WAIT_DURATION = wait_duration
var waypoint_index = 1

func _ready():
    if is_active:
        start()

func start():
    is_active = true
    var waypoints = get_node(positions).get_children()
    positions = []
    for i in range(len(waypoints) + 1):
        if i == 0:
            positions.append(position)
        else:
            positions.append(waypoints[i-1].position)
    if waypoint_index == 1:
        next_move(positions)
    DurationTimer.set_wait_time(DURATION)
    DurationTimer.connect("timeout",self, "_on_Timer_timeout", [positions])
    DurationTimer.start()

func next_move(positions):
    if (waypoint_index == len(positions)):
        if loop:
            positions.invert()
            waypoint_index = 1
        else:
            DurationTimer.stop()
            return
    move(position, positions[waypoint_index])
    waypoint_index += 1
    
func stop():
    TweenNode.stop(TweenNode)
    DurationTimer.stop()
    
func move(from, to):
    print(to)
    TweenNode.interpolate_property(self, "position", from, to, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    TweenNode.start()


func _on_PedestalButton_pressed():
    if (not is_active):
        is_active = true
        start()
    else:
        print("STOP!")
        is_active = false
        stop()
        

func _on_Timer_timeout(positions):
    next_move(positions)
