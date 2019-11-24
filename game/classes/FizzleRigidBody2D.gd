extends RigidBody2D

class_name FizzleRigidBody2D

signal fizzled

const DissolveParticles = preload("res://particles/dissolve/DissolveParticles.tscn")
const DissolveMaterial = preload("res://shader/dissolve/DissolveMaterial.tres")

const FIZZLE_DURATION = 2.5
var fizzled = false
var fizzle_time = 0.0

func _ready():
    add_to_group("can-fizzle")

func fizzle():
    emit_signal("fizzled")
    remove_from_group("can-fizzle")
    collision_mask = 0
    collision_layer = 0
    gravity_scale = 0
    linear_velocity = linear_velocity.clamped(50)
    var particles = DissolveParticles.instance()
    material = DissolveMaterial.duplicate()
    add_child(particles)
    particles.restart()
    fizzled = true

func _process(delta):
    if !fizzled: return
    fizzle_time += delta
    if fizzle_time > FIZZLE_DURATION:
        get_parent().remove_child(self)
    else:
        self.get_material().set_shader_param("Clip", fizzle_time / FIZZLE_DURATION)
