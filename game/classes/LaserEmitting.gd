extends Node2D

class_name LaserEmitting

const BinaryLayers = preload("res://Layers.gd").BinaryLayers
const Laser = preload("res://test-elements/laser-emitter/Laser.tscn")

export(bool) var activated = true

var first_laser = null
var test_vec = Vector2.ZERO

onready var parent := get_parent()

func activate():
    activated = true

func deactivate():
    activated = false
    if first_laser != null:
        var l = first_laser
        first_laser = null
        l.free()

func _physics_process(delta):
    if !activated: return
    
    var direction = Vector2.RIGHT.rotated(global_rotation)
    
    var space_state = get_world_2d().direct_space_state
    var results = PortalUtils.intersect_ray(space_state, global_position, global_position + (direction * 10000), [parent], BinaryLayers.FLOOR)
    
    # Simple checksum to see if anything has even changed
    var compare_vec = Vector2.ZERO
    for result in results:
        compare_vec += result.from
        if !result.empty: compare_vec += result.position
    if compare_vec.distance_to(test_vec) < 12: return
    else: test_vec = compare_vec
        
    var parent = self
    var new_first = null
    
    for hit in results:
        var laser = Laser.instance()
        parent.add_child(laser)
        if parent == self: new_first = laser
        parent = laser
        var to = to_local(hit.from) + (direction * 10000) if hit.empty else to_local(hit.position)
        laser.set_line(to_local(hit.from), to + (direction * 32))
        
    if first_laser != null:
        var l = first_laser
        first_laser = new_first
        l.free()
    else:
        first_laser = new_first
