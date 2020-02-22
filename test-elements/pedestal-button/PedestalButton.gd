extends StaticBody2D

onready var anim = $AnimationPlayer
onready var sound = $Sound
var timer

signal pressed
signal released

const activate_sound = preload("res://sounds/pedestal-button/positive.wav")
const deactivate_sound = preload("res://sounds/pedestal-button/negative.wav")


func play_sound(activate):
    sound.set_stream(activate_sound if activate else deactivate_sound)
    sound.play()

func _ready():
    timer = Timer.new()
    timer.one_shot = true
    timer.connect("timeout", self, "release")
    add_child(timer)

func press():
    if !timer.is_stopped(): return
    anim.play("press-button")
    emit_signal("pressed")
    play_sound(true)
    timer.start(1.5)

func release():
    anim.play("release-button")
    play_sound(false)
    emit_signal("released")
