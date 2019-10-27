extends KinematicBody2D

class_name Player


const GRAVITY_VEC = Vector2(0, 5000)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 50 # pixels/sec
const JUMP_SPEED = 1500
const SIDING_CHANGE_SPEED = 10


var linear_vel = Vector2()


# cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $Sprite

func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == BUTTON_LEFT:
            print(get_global_mouse_position ( ))


func _physics_process(delta):
    
    ### MOVEMENT ###

    # Apply gravity
    linear_vel += delta * GRAVITY_VEC
    # Move and slide
    linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
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
    linear_vel.x = lerp(linear_vel.x, target_speed, 0.3)

    # Jumping
    if on_floor and Input.is_action_just_pressed("move_jump"):
        linear_vel.y = -JUMP_SPEED

