extends StaticBody2D

onready var visual_line := $VisualLine
onready var body_area := $BodyArea

var child_bridge = null

func set_line(from: Vector2, direction: Vector2, length: float):
    
    var to = from + (direction * length)
    
    visual_line.clear_points()
    visual_line.add_point(from)
    visual_line.add_point(to)
    
    var line_owner = create_shape_owner(self)
    var line_shape = SegmentShape2D.new()
    line_shape.a = from
    line_shape.b = to
    shape_owner_add_shape(line_owner, line_shape)
    
    var dist = Vector2(-direction.y, direction.x)
    
    var box_owner = body_area.create_shape_owner(self)
    var box_shape = ConvexPolygonShape2D.new()
    box_shape.set_point_cloud(PoolVector2Array([from+dist, to+dist, to-dist, from-dist]))
    body_area.shape_owner_add_shape(box_owner, box_shape)

func delete_now():
    if child_bridge != null:
        child_bridge.delete_now()
    for body in body_area.get_overlapping_bodies():
        if body is RigidBody2D:
            body.sleeping = false
    queue_free()
