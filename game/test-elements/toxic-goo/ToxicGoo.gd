extends Area2D

onready var goo = $GooSprite

func _ready():
    goo.material = goo.material.duplicate()
    goo.material.set_shader_param("sprite_scale", global_scale * 5)
    connect("body_entered", self, "enter_inner_area")

func enter_inner_area(body):
    if body.is_in_group("can-fizzle"):
        body.fizzle()
    elif body.is_in_group("player"):
        body.take_damage(150.0)
