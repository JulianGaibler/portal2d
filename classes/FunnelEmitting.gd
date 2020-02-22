extends Node2D

class_name FunnelEmitting

const BinaryLayers = preload("res://Layers.gd").BinaryLayers
const ExcursionFunnel = preload("res://test-elements/excursion-funnel-emitter/ExcursionFunnel.tscn")

export(bool) var activated = true
export(bool) var inverse = false

var first_funnel = null
var test_vec = Vector2.ZERO

onready var parent := get_parent()

func activate():
    activated = true

func deactivate():
    activated = false
    if first_funnel != null:
        var l = first_funnel
        first_funnel = null
        l.delete_now()

func set_direction(inverse: bool):
    self.inverse = inverse
    if first_funnel != null:
        first_funnel.set_direction(inverse)

func _physics_process(delta):
    if !activated: return
    
    var direction = Vector2.RIGHT.rotated(global_rotation)
    
    var exclude = [parent] + get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("dynamic-prop") + get_tree().get_nodes_in_group("excursion-funnel") + get_tree().get_nodes_in_group("fake-white")

    var space_state = get_world_2d().direct_space_state
    var results = PortalUtils.intersect_ray(space_state, global_position, global_position + (direction * 10000), exclude, BinaryLayers.FLOOR)
    
    # Simple checksum to see if anything has even changed
    var compare_vec = Vector2.ZERO
    for result in results:
        compare_vec += result.from
        if !result.empty: compare_vec += result.position
    if compare_vec.distance_to(test_vec) < 12: return
    else: test_vec = compare_vec
        
    var root = Game.get_scene_root()
    var parent = root
    var new_first = null
    
    for hit in results:
        var funnel = ExcursionFunnel.instance()
        parent.add_child(funnel)
        funnel.set_direction(inverse)
        if parent == root: new_first = funnel
        else: parent.child_beam = funnel
        parent = funnel
        var length = 10000 if hit.empty else hit.position.distance_to(hit.from)
        funnel.set_line(hit.from, (hit.position - hit.from).normalized(), length)
        
    if first_funnel != null:
        var l = first_funnel
        first_funnel = new_first
        l.delete_now()
    else:
        first_funnel = new_first
