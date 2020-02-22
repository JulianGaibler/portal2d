extends KinematicBody2D

onready var animation_player = $AnimationPlayer

func open():
    animation_player.play("open")

func close():
    animation_player.play("close")
