extends Node2D

export var blue_portal_hit_effect: PackedScene
export var orange_portal_hit_effect: PackedScene
    
func generate_blue_hit_effect(hit_position: Vector2) ->void:
    var temp = blue_portal_hit_effect.instance()
    add_child(temp)
    temp.position = hit_position

func generate_orange_hit_effect(hit_position: Vector2) ->void:
    var temp = orange_portal_hit_effect.instance()
    add_child(temp)
    temp.position = hit_position

func _on_Player_fired_blue_portal(hit_position: Vector2):
    generate_blue_hit_effect(hit_position)


func _on_Player_fired_orange_portal(hit_position: Vector2):
    generate_orange_hit_effect(hit_position)
