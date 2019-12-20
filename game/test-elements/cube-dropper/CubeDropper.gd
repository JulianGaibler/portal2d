extends StaticBody2D

onready var bottom_collider := $BottomCollider/CollisionShapeBottom
onready var detection_area := $DetectionArea
onready var light_sprite := $LightSprite
onready var spawn_point := $SpawnPoint

var current_object

var audio_streams = ["res://sounds/cube-dropper/drop1.wav",
                     "res://sounds/cube-dropper/drop2.wav"]
var first_dropped = true

export(bool) var initial_drop = false # If the dropper should initially open once
export(bool) var auto_drop = false # If the dropper should open when a new item has been spawned
export(PackedScene) var object = null # Scene-Object that should be spawned
export(bool) var auto_respawn = false # If destroyed objects should be respawned

func _ready():
    if object:
        _create_object()
        first_dropped = false
    if initial_drop: timed_open()

func _create_object():
    if object != null:
        if current_object != null:
            if auto_respawn:
                current_object.disconnect("tree_exiting", self, "spawn_new")
            # TODO: stop fizzler from playing sound when no cube is visible
            # $Sound.set_stream(load("res://sounds/fizzler/fizzle.wav"))
            # $Sound.play()
            current_object.fizzle()
        var instance = object.instance()
        instance.set_position(spawn_point.get_position())
        if auto_respawn:
            instance.connect("tree_exiting", self, "spawn_new")
        current_object = instance
        add_child(instance)

## Public Methods ##

func spawn_new():
    randomize()
    $Sound.set_stream(load(audio_streams[randi()%audio_streams.size()]))
    $Sound.play()
    _create_object()
    if auto_drop:
        yield(get_tree().create_timer(0.7), "timeout")
    if !first_dropped:
        timed_open()
        first_dropped = true
    else:
        _create_object()
        if auto_drop:
            yield(get_tree().create_timer(0.5), "timeout")
            timed_open()

func open():
    light_sprite.region_rect.position.y = 1600
    bottom_collider.disabled = true
    for body in detection_area.get_overlapping_bodies():
        if body is RigidBody2D:
            body.sleeping = false

func close():
    light_sprite.region_rect.position.y = 1536
    bottom_collider.disabled = false


func timed_open():
    open()
    yield(get_tree().create_timer(1.5), "timeout")
    close()

