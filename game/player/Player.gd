extends KinematicBody2D

class_name Player


const GRAVITY_VEC = Vector2(0, 2500)
const FLOOR_NORMAL = Vector2.UP
const WALK_SPEED = 25 # pixels/sec
const JUMP_SPEED = 650
const SIDING_CHANGE_SPEED = 10
var PUSH = 1000

var linear_velocity = Vector2()

func _physics_process(delta):

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
