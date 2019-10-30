extends KinematicBody2D

class_name Player


const GRAVITY_VEC = Vector2(0, 2500)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 25 # pixels/sec
const JUMP_SPEED = 650
const SIDING_CHANGE_SPEED = 10

var linear_velocity = Vector2()

func _physics_process(delta):

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

