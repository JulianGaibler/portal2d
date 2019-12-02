extends Area2D

const DissolveParticles = preload("res://particles/dissolve/DissolveParticles.tscn")
const DissolveMaterial = preload("res://shader/dissolve/DissolveMaterial.tres")

onready var shader_sprite := $ShaderSprite

func _ready():
    connect("body_entered", self, "enter_inner_area")
    
    shader_sprite.material = shader_sprite.material.duplicate()
    var res = shader_sprite.material.get_shader_param("u_resolution")
#    res.y /= scale.y
    shader_sprite.material.set_shader_param("u_resolution", res)

func enter_inner_area(body):
    if body.is_in_group("can-fizzle"): body.fizzle()
