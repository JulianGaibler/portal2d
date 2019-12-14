extends StaticBody2D

onready var anim = get_node("PedestalColliderButton/AnimationPlayer")
var timer

signal pressed
signal released

func play_sound(source):
    randomize()
    var stream = load(source)
    $Sound.set_stream(stream)
    $Sound.play()

func _ready():
    timer = Timer.new()
    timer.one_shot = true
    timer.connect("timeout", self, "release")
    add_child(timer)

func press():
    if !timer.is_stopped(): return
    anim.play("press-button")
    emit_signal("pressed")
    play_sound("res://sounds/button/button1.wav")
    timer.start(1.5)

func release():
    anim.play("release-button")
    play_sound("res://sounds/button/button2.wav")
    emit_signal("released")
