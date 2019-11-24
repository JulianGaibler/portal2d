extends FizzleRigidBody2D

onready var sprite := $CubeSprite

export(bool) var companion = false

func _ready():
    if companion:
        sprite.region_rect.position.x = 336
    else:
        sprite.region_rect.position.x = 8
        
func activate():
    sprite.region_rect.position.y = 336

func deactivate():
    sprite.region_rect.position.y = 8
