extends StaticBody2D

const COLOR_BLUE = Color("#6fa5ad")
const COLOR_ORANGE = Color("#dcba54")

onready var detection_area := $DetectionArea
onready var plate_node := $PlateCollisionPolygon
onready var lights := $Light2D
onready var tween := $Tween

signal pressed
signal released

var bodies_in_area = 0

func play_sound(source):
    randomize()
    var stream = load(source)
    $Sound.set_stream(stream)
    $Sound.play()

func _ready():
    detection_area.connect("body_exited", self, "leave_area")
    detection_area.connect("body_entered", self, "enter_area")

func leave_area(body):
    if body.is_in_group("cube") or body.is_in_group("player"):
        bodies_in_area -= 1
        if body.name == "WeightedCube": body.deactivate()
        if bodies_in_area == 0:
            tween.interpolate_property(plate_node, "position", plate_node.position, Vector2(0,0), .1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
            tween.start()
            lights.color = COLOR_BLUE
            play_sound("res://sounds/floor-button/releasing.wav")
            emit_signal("released")

func enter_area(body):
    if body.is_in_group("cube") or body.is_in_group("player"):
        bodies_in_area += 1
        if body.name == "WeightedCube": body.activate()
        if bodies_in_area == 1:
            tween.interpolate_property(plate_node, "position", plate_node.position, Vector2(0,3), .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
            tween.start()
            lights.color = COLOR_ORANGE
            play_sound("res://sounds/floor-button/pressing.wav")
            emit_signal("pressed")
