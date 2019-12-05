extends Node2D

class_name BridgeEmitting

const BinaryLayers = preload("res://Layers.gd").BinaryLayers
const LightBridge = preload("res://test-elements/light-bridge-emitter/LightBridge.tscn")

export(bool) var activated = true

var first_bridge = null
var test_vec = Vector2.ZERO

onready var parent := get_parent()

func activate():
    activated = true

func deactivate():
    activated = false
    if first_bridge != null:
        var l = first_bridge
        first_bridge = null
        l.free()

func _physics_process(delta):
    if !activated: return
    
    var direction = Vector2.RIGHT.rotated(global_rotation)
    
    var exclude = [parent] + get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("dynamic-prop") + get_tree().get_nodes_in_group("light-bridge")

    var space_state = get_world_2d().direct_space_state
    var results = PortalUtils.intersect_ray(space_state, global_position, global_position + (direction * 10000), exclude, BinaryLayers.FLOOR)
    
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
        var bridge = LightBridge.instance()
        parent.add_child(bridge)
        if parent == self: new_first = bridge
        parent = bridge
        var to = to_local(hit.from) + (hit.normal * 10000) if hit.empty else to_local(hit.position)
        bridge.set_line(to_local(hit.from), to)
        
    if first_bridge != null:
        var l = first_bridge
        first_bridge = new_first
        l.free()
    else:
        first_bridge = new_first
