extends Node2D


export var blue_hit_effect: PackedScene
export var orange_hit_effect: PackedScene

const PortalType = preload("res://portal/Portal.gd").PortalType
const PortalOrientation = preload("res://portal/Portal.gd").PortalOrientation
const Portal = preload("res://portal/Portal.tscn")

# load the portals
onready var blue_portal = preload("res://portal/Portal.tscn")
onready var orange_portal = preload("res://portal/Portal.tscn")


# generate the hit effect and create the portals
func generate_blue_hit_effect(hit_position: Vector2) ->void:
    var temp = blue_hit_effect.instance()
    add_child(temp)
    temp.position = hit_position

func spawn_blue_portal(hit_position: Vector2, normal: Vector2, deg: float)->void:
    print(deg)
    # setting the default to down because the degree we need to check is way smaller
    # since it does not cross the 0 threshold
    var orientation = PortalOrientation.DOWN
    # getting the correct orientation
    if 90 < deg and deg < 270:
        orientation = PortalOrientation.UP

    var instance = Portal.instance()
    add_child(instance)
    instance.position = hit_position
    # rotating the portal to fit the white layer
    instance.rotation_degrees = rad2deg(atan2(normal.y, normal.x))
    var type = PortalType.BLUE_PORTAL
    instance.initiate(type, orientation)

func _on_Player_fired_blue_portal(hit_position: Vector2, normal: Vector2, deg: float):
    generate_blue_hit_effect(hit_position)
    spawn_blue_portal(hit_position, normal, deg * -1)

# ------- ORANGE PORTAL -------
# generate the hit effect and create the portals
func generate_orange_hit_effect(hit_position: Vector2) ->void:
    var temp = orange_hit_effect.instance()
    add_child(temp)
    temp.position = hit_position

func spawn_orange_portal(hit_position: Vector2, normal: Vector2, deg: float)->void:
    var instance = Portal.instance()
    add_child(instance)
    var orientation = PortalOrientation.DOWN
    # getting the correct orientation
    if 90 < deg and deg < 270:
        orientation = PortalOrientation.UP
    instance.position = hit_position
    # rotating the portal to fit the white layer
    instance.rotation_degrees = rad2deg(atan2(normal.y, normal.x))
    var type = PortalType.ORANGE_PORTAL
    instance.initiate(type, orientation)

func _on_Player_fired_orange_portal(hit_position: Vector2, normal: Vector2, deg: float):
    generate_orange_hit_effect(hit_position)
    spawn_orange_portal(hit_position, normal, deg * -1)
