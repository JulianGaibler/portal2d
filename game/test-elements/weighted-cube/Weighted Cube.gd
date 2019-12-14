extends FizzleRigidBody2D

onready var sprite := $CubeSprite

const collision_audio_streams = [
    "res://sounds/impacts/impact1.wav",
    "res://sounds/impacts/impact2.wav",
    "res://sounds/impacts/impact3.wav",
    "res://sounds/impacts/impact4.wav",
    "res://sounds/impacts/impact5.wav",
    ]

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

# TODO:
# play sound on collision

func play_colliding_sound():
    randomize()
    var stream = load(collision_audio_streams[randi()%collision_audio_streams.size()])
    $TransitionSound.set_stream(stream)
    $TransitionSound.play()
