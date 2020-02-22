extends StaticBody2D

onready var emitter := $Emitter
onready var audio := $EmitterLoopAudio

export(bool) var start_active = true
export(bool) var start_reversed = false

func _ready():
    if !start_active: emitter.deactivate()
    else: audio.play()
    if start_reversed: emitter.set_direction(true)

func activate():
    audio.play()
    emitter.activate()
        
func deactivate():
    audio.stop()
    emitter.deactivate()

func set_direction(inverse: bool):
    emitter.set_direction(inverse)
