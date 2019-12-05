extends StaticBody2D

onready var laser_detection = $LaserDetection

signal activated
signal deactivated

var lasers_in_area = 0

func _ready():
    laser_detection.connect("body_exited", self, "leave_area")
    laser_detection.connect("body_entered", self, "enter_area")


func _physics_process(delta):
    print(laser_detection.get_overlapping_bodies())

func leave_area(body):
    lasers_in_area -= 1
    if lasers_in_area == 0:
        emit_signal("deactivated")
        

func enter_area(body):
    lasers_in_area += 1
    if lasers_in_area == 1:
        emit_signal("activated")
