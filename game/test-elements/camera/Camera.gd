extends Area2D

const BinaryLayers = preload("res://Layers.gd").BinaryLayers
const half_rotation = deg2rad(180)
const quarter_rotation = deg2rad(90)

onready var camera_body := $CameraSprite/StaticBody2D
onready var tween := $Tween

var tracked_player = null

func _ready():
    connect("body_exited", self, "leave_area")
    connect("body_entered", self, "enter_area")

func _physics_process(delta):
    
    var goal = quarter_rotation
    
    if tracked_player != null:
        var space_state = get_world_2d().direct_space_state
        var result = space_state.intersect_ray(camera_body.global_position, tracked_player.global_position, [camera_body], BinaryLayers.FLOOR | BinaryLayers.BLUE_OUTER | BinaryLayers.ORANGE_OUTER)
        if result.empty() or result.collider != tracked_player: return
        goal = (tracked_player.global_position - camera_body.global_position).angle()
    
    if scale.x < 0: goal *= -1
    else: goal += half_rotation
    if (goal != camera_body.rotation):
        tween.interpolate_property(camera_body, "rotation", camera_body.rotation, goal, .3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
        tween.start()


func enter_area(body):
    if tracked_player == null and body.is_in_group("player"):
        tracked_player = body

func leave_area(body):
    tracked_player = null
