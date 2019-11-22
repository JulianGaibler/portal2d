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
    print(hit_position)
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
    if can_place_portal(hit_position, normal):
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

func can_place_portal(hit_position: Vector2, normal: Vector2)->bool:
    # calculating the degree in rad 
    var rad = atan2(normal.y, normal.x)
    # creating 2 points apart each other (upper and lower boundaries)
    # rotating the so the align with the portal and match the outter points
    var point1 = Vector2(0, 100).rotated(rad)
    var point2 = Vector2(0, -100).rotated(rad)
    # calculating the outter points
    var upper_end_point = hit_position + point1
    var lower_end_point = hit_position + point2
    # getting the 2d world
    var space_state = get_world_2d().direct_space_state    
    # calculating if one of the points is colliding with the world where it should not
    var collision1 = space_state.intersect_point(upper_end_point)
    var collision2 = space_state.intersect_point(lower_end_point)
    
    if (len(collision1) == 0 and len(collision2) == 0):
         return true
    else:
         return false
    
    

func _on_Player_fired_orange_portal(hit_position: Vector2, normal: Vector2, deg: float):
    generate_orange_hit_effect(hit_position)
    if can_place_portal(hit_position, normal):
        spawn_orange_portal(hit_position, normal, deg * -1)
