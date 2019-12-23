extends Area2D

signal enter
signal leave

export(bool) var only_player = false

func _ready():
    connect("body_entered", self, "enter_area")
    connect("body_exited", self, "leave_area")
    
func enter_area(body):
    if only_player and !body.is_in_group("player"):
        return
    emit_signal("enter")

func leave_area(body):
    if only_player and !body.is_in_group("player"):
        return
    emit_signal("leave")
