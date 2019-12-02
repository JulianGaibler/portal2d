extends StaticBody2D

onready var col := $CollisionShape2D

func _ready():
	pass

#moves CollisionShape
func _on_FloorButton_touch():
	col.set_scale(Vector2(0.1,0.1))
	col.set_position(Vector2(-1000,-1000)) #eventuell größer machen

#moves CollisionShape back
func _on_FloorButton_no_touch():
	
	col.set_scale(Vector2(1,1))
	col.set_position(Vector2(0,-117))
