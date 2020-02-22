extends FizzleRigidBody2D

onready var lens_sprite = $LensSprite
onready var laser_detection = $LaserDetection
onready var emitter = $Emitter

var lasers_in_area = 0

func _ready():
    laser_detection.connect("body_exited", self, "leave_area")
    laser_detection.connect("body_entered", self, "enter_area")

func fizzle():
    lens_sprite.visible = false
    laser_detection.disconnect("body_exited", self, "leave_area")
    laser_detection.disconnect("body_entered", self, "enter_area")
    emitter.deactivate()
    .fizzle()


func leave_area(body):
    lasers_in_area -= 1
    if lasers_in_area == 0  and emitter.activated:
        emitter.deactivate()
        

func enter_area(body):
    lasers_in_area += 1
    if lasers_in_area == 1 and !emitter.activated:
        emitter.activate()

