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
    test_vec = Vector2.ZERO

func deactivate():
    activated = false
    if first_bridge != null:
        var l = first_bridge
        first_bridge = null
        l.delete_now()

func _physics_process(delta):
    if !activated: return
    
    var direction = Vector2.RIGHT.rotated(global_rotation)
    
    var exclude = [parent] + get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("dynamic-prop") + get_tree().get_nodes_in_group("light-bridge") + get_tree().get_nodes_in_group("fake-white")

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
        var bridge = LightBridge.instance()
        parent.add_child(bridge)
        if parent == root: new_first = bridge
        else: parent.child_bridge = bridge
        parent = bridge
        var length = 10000 if hit.empty else hit.position.distance_to(hit.from)
        bridge.set_line(hit.from, (hit.position - hit.from).normalized(), length)
        
    if first_bridge != null:
        var l = first_bridge
        first_bridge = new_first
        l.delete_now()
    else:
        first_bridge = new_first
