extends Node2D

const Layers = preload("res://Layers.gd").Layers
enum {BLUE_PORTAL, ORANGE_PORTAL}

# for debugging
var worked = false
# This is the area that get's carved out
var portal_hole = PoolVector2Array([Vector2(-96, 128), Vector2(-96, -128), Vector2(32, -128), Vector2(32, 128)])
# type of the portal (important for collision)
var portal_type = BLUE_PORTAL

var outer_area
var inner_area


func _ready():
	outer_area = get_node("OuterArea")
	inner_area = get_node("InnerArea")
	
	outer_area.connect("body_entered", self, "enter_outer_area")
	outer_area.connect("body_exited", self, "leave_outer_area")
	inner_area.connect("body_entered", self, "enter_inner_area")
	inner_area.connect("body_exited", self, "leave_inner_area")

func enter_outer_area(body):
	match portal_type:
		BLUE_PORTAL:
			body.set_collision_layer_bit(Layers.BLUE_INNER, true)
			body.set_collision_layer_bit(Layers.BLUE_OUTER, true)
			body.set_collision_mask_bit(Layers.BLUE_INNER, true)
			body.set_collision_mask_bit(Layers.BLUE_OUTER, true)
		ORANGE_PORTAL:
			body.set_collision_layer_bit(Layers.ORANGE_INNER, true)
			body.set_collision_layer_bit(Layers.ORANGE_OUTER, true)
			body.set_collision_mask_bit(Layers.ORANGE_INNER, true)
			body.set_collision_mask_bit(Layers.ORANGE_OUTER, true)

func leave_outer_area(body):
	match portal_type:
		BLUE_PORTAL:
			body.set_collision_layer_bit(Layers.BLUE_INNER, false)
			body.set_collision_layer_bit(Layers.BLUE_OUTER, false)
			body.set_collision_mask_bit(Layers.BLUE_INNER, false)
			body.set_collision_mask_bit(Layers.BLUE_OUTER, false)
		ORANGE_PORTAL:
			body.set_collision_layer_bit(Layers.ORANGE_INNER, false)
			body.set_collision_layer_bit(Layers.ORANGE_OUTER, false)
			body.set_collision_mask_bit(Layers.ORANGE_INNER, false)
			body.set_collision_mask_bit(Layers.ORANGE_OUTER, false)

func enter_inner_area(body):
	body.set_collision_layer_bit(Layers.FLOOR, false)
	body.set_collision_mask_bit(Layers.FLOOR, false)

func leave_inner_area(body):
	body.set_collision_layer_bit(Layers.FLOOR, true)
	body.set_collision_mask_bit(Layers.FLOOR, true)

func _process(delta):
	if (worked): return
	worked = true
	
	# Get polygons from colliders inside "OuterArea"
	var polygons = get_node("ScanArea").calculate_polygon()
	
	# Bring polygons from world space into local space
	for i in range(polygons.size()):
		polygons[i] = PolygonUtils.transform_polygon(polygons[i], global_transform.inverse())
	
	# Carve out hole for portal.
	var carved_polygons = []
	for polygon in polygons:
		for new_polygon in Geometry.clip_polygons_2d(polygon, portal_hole): #clip_polygons_2d
			carved_polygons.append(new_polygon)
	
	# Take care of collision layer and mask.
	var collider = create_collider(carved_polygons)
	match portal_type:
		BLUE_PORTAL: collider.set_collision_layer(Layers.BLUE_INNER)
		ORANGE_PORTAL: collider.set_collision_layer(Layers.ORANGE_INNER)
	
	# create new collider from polygons
	add_child(collider)
	
	
func create_collider(polygons: Array) -> StaticBody2D:
	var colliderArea2D = StaticBody2D.new()
	
	for polygon in polygons:
		var collider = CollisionPolygon2D.new()
		collider.polygon = polygon
		colliderArea2D.add_child(collider)
	
	return colliderArea2D
