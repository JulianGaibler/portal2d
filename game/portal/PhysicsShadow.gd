extends KinematicBody2D

var parent = null
var matrix = null
var linked_normal = null

var gravity_vec
var gravity

func _ready():
    gravity_vec = Physics2DServer.area_get_param(get_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY_VECTOR)
    gravity = Physics2DServer.area_get_param(get_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY)

func _physics_process(delta):
    move_and_slide(Vector2.ZERO, Vector2( 0, 0 ), false, 4, 0.785398, false)
    
    for index in get_slide_count():
        var collision = get_slide_collision(index)
        if parent.is_in_group("dynamic-prop"):
            parent.apply_central_impulse(matrix.multiply_vec(collision.normal) * -5500)
