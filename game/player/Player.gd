extends KinematicBody2D
class_name Player

signal health_changed

const BinaryLayers = preload("res://Layers.gd").BinaryLayers

# Player related Values
var health = 100
var dead = false
const live_regeneration_rate = 50

# portal gun node detection
onready var portalgun := $PortalGun

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
    
    var direct_state = Physics2DServer.body_get_direct_state(get_rid())
    var gravity_vec = direct_state.total_gravity * 2.0
    var gravity_n = gravity_vec.normalized()
    
    var linear_damp = 1.0 - delta * direct_state.total_linear_damp
    if linear_damp < 0: linear_damp = 0

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
    linear_velocity += delta * gravity_vec
    # Apply linear damp
    linear_velocity *= linear_damp
    # Move and slide
    linear_velocity = move_and_slide(linear_velocity, -gravity_n, false, 4, 0.785398, false)

    ## Physics ##

    # Apply a force to every collider we touched
    for index in get_slide_count():
        var collision = get_slide_collision(index)
        if collision.collider.is_in_group("dynamic-prop"):
            collision.collider.apply_central_impulse(-collision.normal * PUSH)
    
    # Detect if we are on floor - only works if called *after* move_and_slide
    var on_floor = is_on_floor()

    # Rotating
    if (rotation_degrees == 0):
        pass
    elif (rotation_degrees < 1 && rotation_degrees > -1):
        rotate(-rotation)
    else:
        var x = min(linear_velocity.x, 2500)/2500
        var y = 0.147 - 0.177*x + 0.057*pow(x,2)
        rotate(lerp(0, -rotation, y))

    var target_speed = 0
    
    if !dead:
        regenerate_live(delta)
        
        ## Control ##
        linear_velocity = linear_velocity.rotated(FLOOR_NORMAL.angle_to(-gravity_n))
        # Horizontal movement
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
    
    linear_velocity.x = lerp(linear_velocity.x, target_speed, (0.2 if on_floor else 0.01))
    
    # Jumping
    if !dead and on_floor and Input.is_action_just_pressed("move_jump"):
        linear_velocity.y = -JUMP_SPEED

    linear_velocity = linear_velocity.rotated(-FLOOR_NORMAL.angle_to(-gravity_n))

func _input(event):
    if dead: return
    
    if Input.is_action_just_pressed("take_damage"):
        take_damage(20)
    
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

    # handling if the portal gun is shot
    if event.is_action_pressed("shoot_blue_portal"):
        portalgun.primary_fire()
    
    if event.is_action_pressed("shoot_orange_portal"):
        portalgun.secondary_fire()


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
    if held_object.has_method("picked_up"): held_object.picked_up(true)
    held_object.connect("fizzled", self, "release_object")
    
func release_object():
    held_object.disconnect("fizzled", self, "release_object")
    if held_object.has_method("picked_up"): held_object.picked_up(false)
    held_object.gravity_scale = 1
    held_object.linear_velocity = linear_velocity
    held_object = null
    
func take_damage(amount):
    health -= amount
    if (health <= 0): die()
        
func regenerate_live(delta):
    health += live_regeneration_rate * delta
    health = min(100.0, health)
    if health != 100.0: emit_signal("health_changed", health/100.0)
       

func die():
    if dead: return
    if held_object != null:
        release_object()
    dead = true
    regenerate_live(0)
    yield(get_tree().create_timer(0.5), "timeout")
    Game.reload_scene_fade()
