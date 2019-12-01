extends Node2D

const Portal = preload("res://portal/Portal.tscn")
const PortalOrientation = preload("res://portal/Portal.gd").PortalOrientation
const PortalType = preload("res://portal/Portal.gd").PortalType
const BinaryLayers = preload("res://Layers.gd").BinaryLayers

onready var parent = get_parent()
onready var active_end := $ActiveEnd

func primary_fire():
    shoot_portal(PortalType.BLUE_PORTAL)

func secondary_fire():
    shoot_portal(PortalType.ORANGE_PORTAL)


func shoot_portal(type):
    var direction = (active_end.global_position - global_position).normalized()
    var space_state = get_world_2d().direct_space_state
    var hit = space_state.intersect_ray(active_end.global_position, active_end.global_position + (direction * 3000), [parent], BinaryLayers.FLOOR | BinaryLayers.WHITE)
    if hit.empty(): return
    if !can_place_portal(hit.position, hit.normal): return
    var deg = rad2deg(Vector2.RIGHT.angle_to(direction))
    spawn_portal(hit.position, hit.normal, deg, type)

func spawn_portal(hit_position: Vector2, normal: Vector2, deg: float, type):
    var instance = Portal.instance()
    get_tree().get_root().add_child(instance)
    var orientation = PortalOrientation.UP
    # getting the correct orientation
    if normal == Vector2.UP or normal == Vector2.DOWN:
        if (deg < 90 and deg > 0) or (deg > -180 and deg < -90):
            orientation = PortalOrientation.DOWN
    else:
        if deg < 90 and deg > -90:
            orientation = PortalOrientation.DOWN
    instance.position = hit_position
    # rotating the portal to fit the white layer
    instance.rotation_degrees = rad2deg(atan2(normal.y, normal.x))
    instance.initiate(type, orientation)

func can_place_portal(hit_position: Vector2, normal: Vector2) -> bool:
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
    
    return (len(collision1) == 0 and len(collision2) == 0)
