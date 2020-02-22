extends Node2D

onready var sprite = $Sprite

func _ready():
    set_process(false)

func set_on():
    sprite.region_rect.position.x = 256

func set_off():
    sprite.region_rect.position.x = 0
