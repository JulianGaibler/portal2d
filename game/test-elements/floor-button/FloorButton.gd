extends StaticBody2D

onready var detection_area := $DetectionArea
onready var plate_node := $PlateCollisionPolygon
onready var lights_sprite := $LightsSprite
onready var tween := $Tween

signal pressed
signal released

var bodies_in_area = -1

func play_sound(source):
    randomize()
    var stream = load(source)
    $Sound.set_stream(stream)
    $Sound.play()

func _ready():
    detection_area.connect("body_exited", self, "leave_area")
    detection_area.connect("body_entered", self, "enter_area")

func leave_area(body):
    bodies_in_area -= 1
    if bodies_in_area == 0:
        tween.interpolate_property(plate_node, "position", plate_node.position, Vector2(0,0), .1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
        tween.start()
        lights_sprite.region_rect.position.y = 256
        play_sound("res://sounds/button/button1.wav")
        emit_signal("released")

func enter_area(body):
    bodies_in_area += 1
    if bodies_in_area == 1:
        tween.interpolate_property(plate_node, "position", plate_node.position, Vector2(0,3), .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
        tween.start()
        lights_sprite.region_rect.position.y = 320
        play_sound("res://sounds/button/button2.wav")
        emit_signal("pressed")
