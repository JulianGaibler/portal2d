extends StaticBody2D

onready var sprite := $Sprite
onready var emitter := $Emitter

enum Orientation {UP, CENTER, DOWN}

export(bool) var start_active = true
export(Orientation) var laser_position = Orientation.CENTER

func activate():
    emitter.activate()
        
func deactivate():
    emitter.deactivate()

func _ready():
    if !start_active:
        emitter.deactivate()
    
    match laser_position:
        Orientation.CENTER:
            emitter.position.y = 0
            sprite.region_rect.position.x = 8
            sprite.scale.y = 0.25
        Orientation.UP:
            emitter.position.y = -32
            sprite.region_rect.position.x = 520
            sprite.scale.y = -0.25
        Orientation.DOWN:
            emitter.position.y = 32
            sprite.region_rect.position.x = 520
            sprite.scale.y = 0.25
