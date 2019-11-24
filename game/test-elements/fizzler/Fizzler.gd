extends Area2D

const DissolveParticles = preload("res://particles/dissolve/DissolveParticles.tscn")
const DissolveMaterial = preload("res://shader/dissolve/DissolveMaterial.tres")

func _ready():
    connect("body_entered", self, "enter_inner_area")

func enter_inner_area(body):
    if body.is_in_group("can-fizzle"): body.fizzle()
