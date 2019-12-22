extends Area2D

signal enter
signal enter_once
signal leave
signal leave_once

export(bool) var only_player = false
var enter_once = true
var leave_once = true

func _ready():
    connect("body_entered", self, "enter_area")
    connect("body_exited", self, "leave_area")
    
func enter_area(body):
    if only_player and !body.is_in_group("player"):
        return
    if enter_once:
        emit_signal("enter_once")
        enter_once = false
    emit_signal("enter")

func leave_area(body):
    if only_player and !body.is_in_group("player"):
        return
    if leave_once:
        emit_signal("leave_once")
        leave_once = false
    emit_signal("leave")
