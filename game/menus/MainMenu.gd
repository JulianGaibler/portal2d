extends Node2D

onready var sign_flicker_audio := $TestchamberSign/FlickerAudio
onready var sign_animation_player := $TestchamberSign/AnimationPlayer
onready var sign_hum_audio := $TestchamberSign/HumAudio
onready var spawn_point := $ObjectSpawn

var instance = null
var next_item = 0
const item = [
    preload("res://test-elements/weighted-cube/Weighted Cube.tscn"),
    preload("res://test-elements/turret/TurretLeft.tscn"),
    preload("res://props/radio/Radio.tscn"),
    preload("res://test-elements/redirection-cube/RedirectionCube.tscn"),
]

func _ready():
    randomize()
    next_item = randi()%item.size()
    sign_animation_player.play("BindPose")
    object_loop()
    yield(get_tree().create_timer(1), "timeout")
    sign_flicker_audio.play()
    sign_animation_player.play("flicker-on")
    yield(get_tree().create_timer(1.65), "timeout")
    sign_hum_audio.play()
    


func object_loop():
    instance = item[next_item].instance()
    next_item = int(fmod(next_item + 1, item.size()))
    add_child(instance)
    instance.position += spawn_point.position
    yield(get_tree().create_timer(15), "timeout")
    instance.fizzle()
    instance.apply_central_impulse(Vector2(0, 300))
    object_loop()
    
func animate_menu_flicker():
    sign_animation_player.play("flicker_change")
    sign_flicker_audio.play(1.0)
    
func animate_menu_off():
    sign_animation_player.play("flicker-off")
    sign_flicker_audio.play(1.5)
