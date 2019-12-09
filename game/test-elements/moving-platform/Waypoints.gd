tool
extends Node2D

var _active_point_index: = 0

func _ready():
    pass

func get_start_position() -> Vector2:
    return get_child(0).global_position

func get_current_point_position() -> Vector2:
    return get_child(_active_point_index).global_position
    
func get_next_point_position():
    _active_point_index = (_active_point_index + 1) % get_child_count()
    return get_current_point_position()
