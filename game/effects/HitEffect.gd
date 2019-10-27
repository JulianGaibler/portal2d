extends Node2D

onready var particle:= $Particles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	particle.emitting = true
	

func _on_Timer_timeout():
	# if the timer calls a timeout the node will disappear 
	# this way it is more memory efficient
	queue_free()
