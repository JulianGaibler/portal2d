extends StaticBody2D

onready var anim = get_node("PedestalColliderButton/AnimationPlayer")
var timer

signal pressed

func _ready():
    timer = Timer.new()
    timer.one_shot = true
    timer.connect("timeout", self, "release")
    add_child(timer)

func press():
    if !timer.is_stopped(): return
    anim.play("press-button")
    emit_signal("pressed")
    timer.start(1.5)

func release():
    anim.play("release-button")
