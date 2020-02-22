extends StaticBody2D

onready var laser_detection = $LaserDetection
onready var large_shape = $LaserDetection/LargeShape2D
onready var small_shape = $LaserDetection/SmallShape2D
onready var sprite := $Sprite

signal activated
signal deactivated

enum Orientation {UP, CENTER, DOWN}

export(Orientation) var laser_position = Orientation.CENTER


var lasers_in_area = 0

func _ready():
    laser_detection.connect("body_exited", self, "leave_area")
    laser_detection.connect("body_entered", self, "enter_area")
    match laser_position:
        Orientation.CENTER:
            large_shape.disabled = false
            sprite.region_rect.position.x = 8
            sprite.scale.y = 0.25
        Orientation.UP:
            small_shape.disabled = false
            small_shape.position.y = -32
            sprite.region_rect.position.x = 520
            sprite.scale.y = -0.25
        Orientation.DOWN:
            small_shape.disabled = false
            small_shape.position.y = 32
            sprite.region_rect.position.x = 520
            sprite.scale.y = 0.25


func leave_area(body):
    lasers_in_area -= 1
    if lasers_in_area == 0:
        emit_signal("deactivated")
        

func enter_area(body):
    lasers_in_area += 1
    if lasers_in_area == 1:
        emit_signal("activated")
