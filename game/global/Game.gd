extends Node

const Game = preload("res://global/Game.tscn")

signal goto_scene

var game_root = Game.instance()
var current_scene
var blend_tween
var blend_rect

func _ready():
    call_deferred("_deferred_ready")

func _deferred_ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)
    root.remove_child(current_scene)

    root.add_child(game_root)
    root.get_child(root.get_child_count() - 1).add_child(current_scene)

    blend_tween = game_root.get_node("BlendLayer/Tween")
    blend_rect = game_root.get_node("BlendLayer/ColorRect")

# Gets current route of the scene
func get_scene_root():
    return current_scene

func goto_scene(path):
    call_deferred("_deferred_goto_scene", path)

func goto_scene_blend(path):
    blend_tween.interpolate_property(blend_rect, "color:a", 0.0, 1.0, .75, Tween.TRANS_LINEAR, Tween.EASE_IN)
    blend_tween.start()
    yield(get_tree().create_timer(0.75), "timeout")
    call_deferred("_deferred_goto_scene", path)
    blend_tween.interpolate_property(blend_rect, "color:a", 1.0, 0.0, .75, Tween.TRANS_LINEAR, Tween.EASE_IN)
    blend_tween.start()

func _deferred_goto_scene(path):
    # It is now safe to remove the current scene
    current_scene.free()
    emit_signal("goto_scene")
    # Load the new scene.
    var s = ResourceLoader.load(path)
    # Instance the new scene.
    current_scene = s.instance()
    # Add it to the active scene, as child of root.
    get_tree().get_root().add_child(current_scene)
    # Optionally, to make it compatible with the SceneTree.change_scene() API.
    get_tree().set_current_scene(current_scene)

