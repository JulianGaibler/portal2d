extends StaticBody2D

onready var emitter := $Emitter

enum Orientation {UP, CENTER, DOWN}

export(bool) var start_active = true

func activate():
    emitter.activate()
        
func deactivate():
    emitter.deactivate()
