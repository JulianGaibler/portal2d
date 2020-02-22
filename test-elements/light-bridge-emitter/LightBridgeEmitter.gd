extends StaticBody2D

onready var emitter := $Emitter

export(bool) var start_active = true

func _ready():
    if !start_active: emitter.deactivate()

func activate():
    emitter.activate()
        
func deactivate():
    emitter.deactivate()
