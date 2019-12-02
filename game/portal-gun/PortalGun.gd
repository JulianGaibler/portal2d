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
    var can_place = can_place_portal(hit.position, hit.normal)
    if (can_place):
        var deg = rad2deg(Vector2.RIGHT.angle_to(direction))
        # if we can place the portal adjust the position
        var adjusted_position = adjust_position(can_place, hit.position, hit.normal)
        spawn_portal(adjusted_position, hit.normal, deg, type)

func move_portal(hit_position, p2, p1, normal, steps):
    # first check if can place the portal now
    var can_place = can_place_portal(hit_position, normal)
    # this function is recursive and tries to find the local minimum
    # it jump for $steps steps into the direction where the other point hits
    # cancel statement
    if (steps == 0 or (can_place.get("can_place_lower") and can_place.get("can_place_upper"))):
        return hit_position

    # get the direction from low -> up
    var direction_between_points = (p2 - p1).normalized()
    var step_size = 15
    # calculate the new position based on the direction between the 2 points
    var new_pos = hit_position + (direction_between_points * step_size * -1)
    # new upper and lower boundaries, called p1 because they can be swapped for recursive matters DRY!!!
    p2 = p2 + (direction_between_points * step_size * -1)
    p1 = p1 + (direction_between_points * step_size * -1)
    steps = steps - 1
    return move_portal(new_pos, p2, p1, normal, steps)
    
func adjust_position(can_place, hit_position, normal) -> Vector2:
    var up = can_place.get("upper_position")
    var low = can_place.get("lower_position")
    var new_pos = hit_position
    
    # check in which direction we need to the move the portal
    
    if (can_place.get("can_place_upper") and not can_place.get("can_place_lower")):
        new_pos = move_portal(hit_position, low, up, normal, 5)
        
    if (can_place.get("can_place_lower") and not can_place.get("can_place_upper")):
        # Note when calling move_portal again we swapped the up and low paramerters,
        # this is because the move_portal function is universally and recusrive and just moves the portal
        # out of the calculated direction of those 2 points
        new_pos = move_portal(hit_position, up, low, normal, 5)
    return new_pos 


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

func can_place_portal(hit_position: Vector2, normal: Vector2) ->Dictionary:
    var rad = atan2(normal.y, normal.x)
    # creating 2 points apart each other (upper and lower boundaries)
    # rotating the points so they align with the portal and match the outter points
    # the portal is 256px long that means that the points are 128px apart from the mid
    var point1 = Vector2(0, 128).rotated(rad)
    var point2 = Vector2(0, -128).rotated(rad)
    # calculating the outter points
    var lower_end_point = hit_position + point1
    var upper_end_point = hit_position + point2
    # getting the 2d world
    var space_state = get_world_2d().direct_space_state
    # calculating if one of the points is colliding with the world where it should not
    var collision1 = space_state.intersect_point(lower_end_point)
    var collision2 = space_state.intersect_point(upper_end_point)
    var result1 = space_state.intersect_ray(upper_end_point, upper_end_point + (normal * -1))
    var result2 = space_state.intersect_ray(lower_end_point, lower_end_point + (normal * -1))
    # default values for return statement
    var can_place_upper = false
    var can_place_lower = false
    # check wether one of the points is outside the white layer
    if (len(result1) != 0):
        if (result1.collider.is_in_group("white_layer")):
            can_place_upper = true
        ## check if the portal could glitch into the wall
        if (len(collision2) != 0):
            can_place_upper = false
    if (len(result2) != 0):
        if (result2.collider.is_in_group("white_layer")):
            can_place_lower = true
        if (len(collision1) != 0):
            can_place_lower = false
    
    if (can_place_upper or can_place_lower):
        return {"can_place_upper": can_place_upper, "upper_position": upper_end_point, "can_place_lower": can_place_lower, "lower_position": lower_end_point}
    else:
        return {}

