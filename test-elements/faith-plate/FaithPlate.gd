extends StaticBody2D

enum Direction { LEFT, UP, RIGHT }

onready var animation_player := $AnimationPlayer
onready var trigger_area := $TriggerArea
onready var sprite := $SpriteCatapult
onready var sound := $LaunchSound

export(Direction) var animation_direction = Direction.RIGHT
export(NodePath) var goal_node
export(int) var height = 700


func _ready():
    trigger_area.connect("body_entered", self, "body_entered")
    if animation_direction == Direction.LEFT:
        animation_player.play("idle-left")

func body_entered(body):
    if !(body is RigidBody2D) and !(body is KinematicBody2D): return
    animation_player.stop(true)
    match animation_direction:
        Direction.UP: animation_player.play("up-throw")
        Direction.RIGHT: animation_player.play("side-throw")
        Direction.LEFT, Direction.RIGHT: animation_player.play("side-throw-left")
    sound.play()
    var data = calculate_curve(get_node(goal_node).global_position, body)
    var v = data[0]
    update()

    if body is RigidBody2D:
        body.linear_velocity = v
    elif body is KinematicBody2D:
        body.linear_velocity = v

func calculate_curve(target: Vector2, body):
    var direct_state = Physics2DServer.body_get_direct_state(body.get_rid())
    var gravity = -direct_state.total_gravity.length()

    var linear_damp = 1.0 - direct_state.total_linear_damp
    if linear_damp < 0: linear_damp = 0
    
    var position = body.global_position

    var displacement_y = target.y - position.y
    var displacement_x =target.x - position.x
    var time = (sqrt(-2.0*height/(gravity/linear_damp)) + sqrt(2.0*(displacement_y - height)/(gravity/linear_damp)))
    var velocity_y = sqrt(-2.0 * (gravity/linear_damp) * height)
    var velocity_x = displacement_x / time
    
    return [Vector2(velocity_x, -velocity_y), time]
    
    
    
    
