extends StaticBody2D

onready var door_collider := $DoorBody/CollisionShape2D
onready var lights_sprite := $DoorLightSprite
onready var door_sprite := $DoorSprite
onready var tween := $Tween

export(bool) var start_open = true

func _ready():
    if start_open:
        door_collider.scale = Vector2(0,0)
        door_collider.position = Vector2(0,112)
        door_sprite.region_rect.position.y = 960
        lights_sprite.region_rect.position.x = 1408

func close():
    tween.interpolate_property(door_sprite, "region_rect:position:y", door_sprite.region_rect.position.y, 192, .8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()
    # Workaround until door_collider.disabled is working again
    door_collider.scale = Vector2(1,1)
    door_collider.position = Vector2(0,0)
    
    lights_sprite.region_rect.position.x = 1152
        

func open():
    tween.interpolate_property(door_sprite, "region_rect:position:y", door_sprite.region_rect.position.y, 960, .8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()
    # Workaround until door_collider.disabled is working again
    door_collider.scale = Vector2(0,0)
    door_collider.position = Vector2(0,112)
    
    lights_sprite.region_rect.position.x = 1408
