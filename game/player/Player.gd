extends KinematicBody2D

class_name Player

const BinaryLayers = preload("res://Layers.gd").BinaryLayers

# portal gun node detection
onready var portalgun := $PortalGun
onready var ray := $PortalGun/RayCast2D

signal fired_blue_portal
signal fired_orange_portal
signal camera_fired_portal


const GRAVITY_VEC = Vector2(0, 2500)
const FLOOR_NORMAL = Vector2.UP
const WALK_SPEED = 25 # pixels/sec
const JUMP_SPEED = 650
const SIDING_CHANGE_SPEED = 10
var PUSH = 1000

var linear_velocity = Vector2()
var held_object = null

# portalgun orientation in degree
var deg = 0

func _physics_process(delta):

    if portalgun != null:
        # rotate the portal gun
        deg = rotate_portalgun(get_global_mouse_position())

    if held_object:
        var origin = global_position
        origin.y -= 90
        var direction = (get_global_mouse_position() - origin).normalized()
        var to = origin + (direction * 150)

        var dist = held_object.global_transform.origin.distance_to(to)
        if dist > 200: release_object()
        else:
            held_object.linear_velocity = linear_velocity
            held_object.apply_central_impulse((to - held_object.global_transform.origin).normalized() * to.distance_to(held_object.global_transform.origin) * 150)
            
            

    ## Movement ##
    
    # Apply gravity
    linear_velocity += delta * GRAVITY_VEC
    # Move and slide
    linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL, false, 4, 0.785398, false)

    ## Physics ##

    # Apply a force to every collider we touched
    for index in get_slide_count():
        var collision = get_slide_collision(index)
        if collision.collider.is_in_group("dynamic-prop"):
            collision.collider.apply_central_impulse(-collision.normal * PUSH)
    
    # Detect if we are on floor - only works if called *after* move_and_slide
    var on_floor = is_on_floor()

    ## Control ##

    # Horizontal movement
    var target_speed = 0
    if Input.is_action_pressed("move_left"):
        if !target_speed == -WALK_SPEED:
            target_speed -= 25
    if Input.is_action_pressed("move_right"):
        if !target_speed == WALK_SPEED:
            target_speed += 25
    
    if abs(target_speed) > WALK_SPEED:
        if target_speed < 0:
            target_speed = -WALK_SPEED
        else:
            target_speed = WALK_SPEED

    target_speed *= WALK_SPEED
    linear_velocity.x = lerp(linear_velocity.x, target_speed, (0.3 if on_floor else 0.025))

    # Jumping
    if on_floor and Input.is_action_just_pressed("move_jump"):
        linear_velocity.y = -JUMP_SPEED

    # Rotating
    if (rotation_degrees == 0):
        pass
    elif (rotation_degrees < 1 && rotation_degrees > -1):
        rotate(-rotation)
    else:
        var x = min(linear_velocity.x, 2500)/2500
        var y = 0.147 - 0.177*x + 0.057*pow(x,2)
        rotate(lerp(0, -rotation, y))

func _input(event):
    if Input.is_action_just_pressed("interact"):
        # If the player is already holding something, they let it go
        if held_object != null:
            release_object()
            return
        # The players root is at their feet, so let's lift it to the center
        var origin = global_position
        origin.y -= 90
        # Normalized direction vector from the player to the mouse pointer
        var direction = (get_global_mouse_position() - origin).normalized()
        
        # Raycast 200 pixel from the player to the mouse pointer
        var space_state = get_world_2d().direct_space_state
        var result = space_state.intersect_ray(origin, origin + (direction * 200), [self], BinaryLayers.FLOOR | BinaryLayers.INTERACTION)
        if !result.empty():
            if result.collider.is_in_group("can-press"): result.collider.press()
            elif result.collider.is_in_group("can-pickup"): hold_object(result.collider)


# handling input for shooting
func _unhandled_input(event):
    
    # getting the object of the white layer to check if we hit it
    var whitelayer = get_node("../WhiteLayer")
    
    # this is needed to keep the collision with other objects and make it only possible
    # to hit the whitelayer in a direct way
    
    # handling if the portal gun is shot
    if event.is_action_pressed("shoot_blue_portal") and ray.is_colliding():
        # we check if we only hit the white layer while keeping the collision with other objects
        if (whitelayer == ray.get_collider()):
            # getting the normal (pointing away from the white layer) for portal rotaion
            var white_layer_normal = ray.get_collision_normal()
            # emitting signal to let everyone know we shot a portal and give them the collision point
            emit_signal("fired_blue_portal", ray.get_collision_point(), white_layer_normal, deg)
            emit_signal("camera_fired_portal")
            
            
    if event.is_action_pressed("shoot_orange_portal") and ray.is_colliding():
        # we check if we only hit the white layer while keeping the collision with other objects
        if (whitelayer == ray.get_collider()):
            # getting the normal (pointing away from the white layer) for portal rotaion
            var white_layer_normal = ray.get_collision_normal()
            # emitting signal to let everyone know we shot a portal and give them the collision point
            emit_signal("fired_orange_portal", ray.get_collision_point(), white_layer_normal, deg)
            emit_signal("camera_fired_portal")

# used to rotate the portalgun (with y offset of 40 around moving player)
func rotate_portalgun(point_direction: Vector2)->float:
    # get player position
    var player_pos = get_position()
    # calculate the distance between x of player and x of mouse aim
    var x_dist =  player_pos.x - point_direction.x 
    # calculate the distance between y of player and y of mouse aim
    var y_dist =  player_pos.y - point_direction.y 
    # we need to add around 95 pixels to the y value because the position of the
    # player is measured at the bottom
    y_dist = y_dist - 95
    
    # calculate the arc tan from the distances
    # using atan2 since it does not allow division by 0
    var temp = rad2deg(atan2(y_dist, x_dist)) - 180
    portalgun.rotation_degrees = temp
    return temp

func hold_object(collider):
    held_object = collider
    held_object.gravity_scale = 0
    
func release_object():
    held_object.gravity_scale = 1
    held_object.linear_velocity = linear_velocity
    held_object = null
