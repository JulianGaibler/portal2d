extends KinematicBody2D

onready var visual_line := $VisualLine

func set_line(from: Vector2, to: Vector2):
    visual_line.clear_points()
    visual_line.add_point(from)
    visual_line.add_point(to)
    
    var owner = create_shape_owner(self)
    
    var shape = SegmentShape2D.new()
    shape.a = from
    shape.b = to
    
    shape_owner_add_shape(owner, shape)
