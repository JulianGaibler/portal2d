extends Area2D

var tracked_object = null
var tracked_object_number = 0


func _ready():
    connect("body_entered", self, "enter_area")
    connect("body_exited", self, "leave_area")
    
func enter_area(body):
    if body.is_in_group("can-pickup"):
        tracked_object_number += 1
        tracked_object = body
    elif body.is_in_group("player") and tracked_object != null and tracked_object_number > 0:
        body.hold_object(tracked_object)

func leave_area(body):
    if body.is_in_group("can-pickup"):
        tracked_object_number -= 1
