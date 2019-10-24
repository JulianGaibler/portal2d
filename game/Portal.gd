extends Node2D

var worked = false

func _process(delta):
	if (worked): return
	worked = true
	
	# Get polygons from colliders inside "OuterArea"
	var outerArea = get_node("OuterArea")
	var polygons = outerArea.calculate_polygon()
	
	# Bring polygons from world space into local space
	for i in range(polygons.size()):
		polygons[i] = PolygonUtils.transform_polygon(polygons[i], global_transform.inverse())
	
	# TODO: Carve out hole for portal.
	
	# TODO: Take care of collision layer and mask.
	
	# create new collider from polygons
	add_child(create_collider(polygons))
	
	
func create_collider(polygons: Array) -> StaticBody2D:
	var colliderArea2D = StaticBody2D.new()
	
	for polygon in polygons:
		var collider = CollisionPolygon2D.new()
		collider.polygon = polygon
		colliderArea2D.add_child(collider)
	
	return colliderArea2D