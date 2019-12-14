extends Node2D

onready var visual_line_front := $VisualLineFront
onready var visual_line_back := $VisualLineBack
onready var upper_area := $UpperArea
onready var lower_area := $LowerArea
onready var center_area := $CenterArea

const blue_low = Color("#24a8ff")
const blue_high = Color("#6f7ae9")
const orange_low = Color("#e9726f")
const orange_high = Color("#ff9024")

const height = Vector2(0, 120)

var direction = Vector2.ZERO
var inverse = false
var child_beam = null

func _ready():
    visual_line_front.material = visual_line_front.material.duplicate()
    visual_line_back.material = visual_line_back.material.duplicate()

func set_line(from: Vector2, direction: Vector2, length: float):
    
    self.direction = direction

    update_gravity()
    
    var to = from + (direction * length)
    
    visual_line_front.clear_points()
    visual_line_front.add_point(from)
    visual_line_front.add_point(to)
    
    visual_line_back.clear_points()
    visual_line_back.add_point(from)
    visual_line_back.add_point(to)
    
    var owner_upper = upper_area.create_shape_owner(self)
    var owner_lower = lower_area.create_shape_owner(self)
    var owner_center = center_area.create_shape_owner(self)
    
    var height = Vector2(-direction.y, direction.x) * 120
    
    var shape_upper = ConvexPolygonShape2D.new()
    shape_upper.set_point_cloud(PoolVector2Array([from, to, to - height, from - height]))
    
    var shape_lower = ConvexPolygonShape2D.new()
    shape_lower.set_point_cloud(PoolVector2Array([from, to, to + height, from + height]))
    
    upper_area.shape_owner_add_shape(owner_upper, shape_upper)
    lower_area.shape_owner_add_shape(owner_lower, shape_lower)

    var shape = SegmentShape2D.new()
    shape.a = from
    shape.b = to
    
    center_area.shape_owner_add_shape(owner_center, shape)

func update_gravity():
    var _direction = -direction if inverse else direction
    center_area.gravity_vec = _direction
    upper_area.gravity_vec = _direction.rotated(0.5 * (-1.0 if inverse else 1.0))
    lower_area.gravity_vec = _direction.rotated(0.5 * (1.0 if inverse else -1.0))

func set_direction(inverse: bool):
    if child_beam != null:
        child_beam.set_direction(inverse)
    self.inverse = inverse
    visual_line_front.get_material().set_shader_param("color_low", orange_low if inverse else blue_low)
    visual_line_front.get_material().set_shader_param("color_high", orange_high if inverse else blue_high)
    visual_line_front.get_material().set_shader_param("speed", -1 if inverse else 1)
    visual_line_back.get_material().set_shader_param("color_low", orange_low if inverse else blue_low)
    visual_line_back.get_material().set_shader_param("color_high", orange_high if inverse else blue_high)
    visual_line_back.get_material().set_shader_param("speed", -1 if inverse else 1)
    update_gravity()

func delete_now():
    if child_beam != null:
        child_beam.delete_now()
    for body in upper_area.get_overlapping_bodies() + lower_area.get_overlapping_bodies():
        if body is RigidBody2D:
            body.sleeping = false
    queue_free()

