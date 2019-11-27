extends Node2D

# Info
# If there is a direct child to the panel called "PanelTransform",
# it will be transformed with the panel

onready var animationPlayer := $AnimationPlayer
onready var panelBase := $PanelArm1/PanelArm2/PanelArm3/PanelArm4/PanelBase/Position2D

# Animation played when the panel gets created
export(String) var initial_animation = null

func _ready():
    var child = get_child(get_child_count()-1)
    if child.name == "PanelTransform":
        var remote_path = RemoteTransform2D.new()
        remote_path.remote_path = child.get_path()
        panelBase.add_child(remote_path)
        remote_path.	update_scale = false
    
    if initial_animation:
        animationPlayer.play(initial_animation)

func play_animation(name):
    animationPlayer.play(name)
