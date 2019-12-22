extends Node2D

onready var sprite = $Sprite

func _ready():
    set_process(false)

func on():
    sprite.region_rect.position.x = 256

func off():
    sprite.region_rect.position.x = 0
