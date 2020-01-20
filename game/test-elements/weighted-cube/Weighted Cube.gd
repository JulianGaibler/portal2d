extends FizzleRigidBody2D

const COLOR_BLUE = Color("#6fa5ad")
const COLOR_PINK = Color("#d1a8ba")
const COLOR_ORANGE = Color("#dcba54")

onready var sprite := $CubeSprite
onready var light := $Light2D
onready var collision_detector := $CollisionDetector
onready var collision_sound := $CollisionSound

const collision_audio_streams = [
    "res://sounds/impacts/impact1.wav",
    "res://sounds/impacts/impact2.wav",
    "res://sounds/impacts/impact3.wav",
    "res://sounds/impacts/impact4.wav",
    "res://sounds/impacts/impact5.wav",
    ]

export(bool) var companion = false

func _ready():
    collision_detector.connect("body_entered", self, "_on_collision")
    if companion:
        sprite.region_rect.position.x = 336
        light.color = COLOR_PINK
    else:
        sprite.region_rect.position.x = 8
        light.color = COLOR_BLUE
        
func activate():
    light.color = COLOR_ORANGE

func deactivate():
    light.color = COLOR_PINK if companion else COLOR_BLUE

# TODO: fix playing collision sound when pushing through portals / fizzler
func _on_collision(body):
    play_colliding_sound()

func play_colliding_sound():
    randomize()
    collision_sound.set_stream(load(collision_audio_streams[randi()%collision_audio_streams.size()]))
    collision_sound.play()
