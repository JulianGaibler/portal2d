extends Node2D

# Info
# If there is a direct child to the panel called "PanelTransform",
# it will be transformed with the panel

onready var animationPlayer := $AnimationPlayer
onready var panelBase := $PanelArm1/PanelArm2/PanelArm3/PanelArm4/PanelBase/Position2D

# Animation played when the panel gets created
export(String) var initial_animation = null

func _ready():
    call_deferred("_ready_deferred")

func _ready_deferred():
    var child = get_child(get_child_count()-1)
    if child.name == "PanelTransform":
        var remote_path = RemoteTransform2D.new()
        panelBase.add_child(remote_path)
        remote_path.	update_scale = false
        remote_path.remote_path = child.get_path()
    if initial_animation:
        animationPlayer.play(initial_animation, -1, 0, true)

func play_animation(name, delay = 0.0, speed = 1.0):
    if delay > 0.0:yield(get_tree().create_timer(delay), "timeout")
    animationPlayer.play(name, -1, speed, false)

func play_animation_rev(name, delay = 0.0, speed = 1.0):
    if delay > 0.0:yield(get_tree().create_timer(delay), "timeout")
    animationPlayer.play(name, -1, -speed, true)
