extends StaticBody2D

onready var emitter := $Emitter

export(bool) var start_active = true
export(bool) var start_reversed = false

func _ready():
    if !start_active: emitter.deactivate()
    if start_reversed: emitter.set_direction(true)

func activate():
    emitter.activate()
        
func deactivate():
    emitter.deactivate()

func set_direction(inverse: bool):
    emitter.set_direction(inverse)
