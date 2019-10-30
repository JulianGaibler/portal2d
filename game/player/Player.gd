extends KinematicBody2D

class_name Player


const GRAVITY_VEC = Vector2(0, 2500)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 25 # pixels/sec
const JUMP_SPEED = 650
const SIDING_CHANGE_SPEED = 10

signal fired_blue_portal
signal fired_orange_portal

var linear_velocity = Vector2()


# cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $Sprite
onready var pointer := $Pointer
onready var ray:=$Pointer/RayCast2D

func rotate_portalgun(point_direction: Vector2)->void:
    # used to rotate the portalgun (with y offset of 40 around moving player)
    
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
    pointer.rotation_degrees = temp 

func _unhandled_input(event):
    # handling if the portal gun is shot
    if event.is_action_pressed("shoot_blue_portal") and ray.is_colliding():
        emit_signal("fired_blue_portal", ray.get_collision_point())
    if event.is_action_pressed("shoot_orange_portal") and ray.is_colliding():
        emit_signal("fired_orange_portal", ray.get_collision_point())

func _physics_process(delta):

    ### Portal Gun
    # rotation around player
    rotate_portalgun(get_global_mouse_position())


    
    ### MOVEMENT ###

    # Apply gravity
    linear_velocity += delta * GRAVITY_VEC
    # Move and slide
    linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
    # Detect if we are on floor - only works if called *after* move_and_slide
    var on_floor = is_on_floor()

    ### CONTROL ###

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
    linear_velocity.x = lerp(linear_velocity.x, target_speed, (0.3 if on_floor else 0.1))

    rotate(lerp(rotation, 0, (0.1 if on_floor else 0.05)) - rotation)

    # Jumping
    if on_floor and Input.is_action_just_pressed("move_jump"):
        linear_velocity.y = -JUMP_SPEED

