extends Area2D

onready var goo = $GooSprite
onready var splash_sound = $SplashSound

const splash_audio_streams = [
    preload("res://sounds/valve_sounds/Water_splash_01.wav"),
    preload("res://sounds/valve_sounds/Water_splash_02.wav"),
    preload("res://sounds/valve_sounds/Water_splash_03.wav"),
    preload("res://sounds/valve_sounds/Water_splash_04.wav"),
    preload("res://sounds/valve_sounds/Water_splash_05.wav"),
]

func _ready():
    goo.material = goo.material.duplicate()
    goo.material.set_shader_param("sprite_scale", global_scale * 2)
    connect("body_entered", self, "enter_inner_area")

func enter_inner_area(body):
    randomize()
    splash_sound.set_stream(splash_audio_streams[randi()%splash_audio_streams.size()])
    splash_sound.play()
    if body.is_in_group("can-fizzle"):
        body.fizzle()
    elif body.is_in_group("player"):
        body.take_damage(150.0)
