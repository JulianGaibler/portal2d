extends StaticBody2D

onready var area := $Area2D
signal touch
signal no_touch

func _ready():
	area.connect("body_exited", self, "leave_area")
	area.connect("body_entered", self, "enter_area")

func enter_area(object):
	emit_signal("touch")
	
func leave_area(object):
	emit_signal("no_touch")
