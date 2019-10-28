extends Area2D

var shoot
export (PackedScene) var laser

onready var Laser_container = get_node("laser")

func _shoot():
	var pew = laser.instance()
	Laser_container.add_child(pew)
	pew.shoot(get_global_mouse_position(), global_position)

