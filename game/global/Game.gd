extends Node

const Game = preload("res://global/Game.tscn")

signal goto_scene

var game_root = Game.instance()
var current_scene
var fade_tween
var fade_rect
var health_rect

# Current Scene has to be set as soon as possible
func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)
    call_deferred("_deferred_ready", root)

# This has to happen in idle-time
func _deferred_ready(root):
    root.remove_child(current_scene)

    root.add_child(game_root)
    root.get_child(root.get_child_count() - 1).add_child(current_scene)

    fade_tween = game_root.get_node("FadeLayer/Tween")
    fade_rect = game_root.get_node("FadeLayer/ColorRect")
    health_rect = game_root.get_node("HealthLayer/ColorRect")
    _connect_player_health()

## Public Methods ##

# Gets current route of the scene
func get_scene_root():
    return current_scene
# Reloads current scene
func reload_scene():
    goto_scene(current_scene.filename)
# Reloads current scene with fade over black
func reload_scene_fade(fade_time: float = 0.75):
    goto_scene_fade(current_scene.filename, fade_time)

func goto_scene(path):
    call_deferred("_deferred_goto_scene", path)

func goto_scene_fade(path, fade_time: float = 0.75):
    fade_tween.interpolate_property(fade_rect, "color:a", 0.0, 1.0, fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
    fade_tween.start()
    yield(get_tree().create_timer(fade_time), "timeout")
    call_deferred("_deferred_goto_scene", path)
    fade_tween.interpolate_property(fade_rect, "color:a", 1.0, 0.0, fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
    fade_tween.start()

## Private Methods ##

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
    _connect_player_health()

func _connect_player_health():
    _update_health(1.0)
    var arr = get_tree().get_nodes_in_group("player")
    if arr.size() > 0:
        arr[0].connect("health_changed", self, "_update_health")

func _update_health(health):
    var inv = 1.0-health
    health_rect.material.set_shader_param("offset", 10.0*inv)
    health_rect.material.set_shader_param("extend", inv)
