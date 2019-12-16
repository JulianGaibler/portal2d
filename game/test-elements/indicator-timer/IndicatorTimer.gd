extends Node2D

onready var disc_shader: Material = $Disc.get_material()
onready var background = $Background

export(float) var time
var remaining = null

signal started
signal stopped

func start():
    emit_signal("started")    
    background.region_rect.position.x = 256
    remaining = time
    disc_shader.set_shader_param("progress", 0.0)  

func _process(delta):
    if remaining == null: return
    
    remaining -= delta
    if remaining <= 0.0:
        stop()
        return
    
    var increment = remaining / time
    
    if increment >= 1.0:
        disc_shader.set_shader_param("progress", 1.0)
        stop()
    elif increment >= 0.875:
        disc_shader.set_shader_param("progress", 0.875)
    elif increment >= 0.75:
        disc_shader.set_shader_param("progress", 0.75)
    elif increment >= 0.625:
        disc_shader.set_shader_param("progress", 0.625)
    elif increment >= 0.5:
        disc_shader.set_shader_param("progress", 0.5)
    elif increment >= 0.375:
        disc_shader.set_shader_param("progress", 0.375)
    elif increment >= 0.25:
        disc_shader.set_shader_param("progress", 0.25)
    elif increment >= 0.125:
        disc_shader.set_shader_param("progress", 0.125)
    elif increment < 0.125:
        disc_shader.set_shader_param("progress", 0.0)

func stop():
    emit_signal("stopped")
    remaining = null
    disc_shader.set_shader_param("progress", 1.0)  
    background.region_rect.position.x = 0
