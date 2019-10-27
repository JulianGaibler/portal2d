extends Node2D

const Layers = preload("res://Layers.gd").Layers
enum PortalType {BLUE_PORTAL = 0, ORANGE_PORTAL = 1}

# This is the area that get's carved out
var portal_hole = PoolVector2Array([Vector2(-96, 128), Vector2(-96, -128), Vector2(32, -128), Vector2(32, 128)])
# type of the portal (important for collision)
export(PortalType) var portal_type = PortalType.BLUE_PORTAL

var static_collider = null
var linked_portal = null
var collider_polygons = []

var outer_area
var inner_area

func _ready():
	
	outer_area = get_node("OuterArea")
	inner_area = get_node("InnerArea")
	
	outer_area.connect("body_exited", self, "leave_outer_area")
	inner_area.connect("body_exited", self, "leave_inner_area")
	inner_area.connect("body_entered", self, "enter_inner_area")
	outer_area.connect("body_entered", self, "enter_outer_area")

# This has to be merged in _ready at one point,
# but cannot be placed in the editor when done so

var worked = false
func _process(delta):
	# BEGIN DEBUG
	if (worked): return
	worked = true
	# END DEBUG
	
	# Detect static colliders around us
	collider_polygons = get_node("ScanArea").calculate_polygon()

	# Register portal
	PortalManager.register_portal(self)

func link_portal(new_portal):
	reset_portal()
	linked_portal = new_portal
	if (new_portal == null): return
	
	# Bring polygons from world space into local space
	for i in range(collider_polygons.size()):
		collider_polygons[i] = PolygonUtils.transform_polygon(collider_polygons[i], global_transform.inverse())
	
	# Carve out hole for portal.
	var carved_polygons = []
	for polygon in collider_polygons:
		for new_polygon in Geometry.clip_polygons_2d(polygon, portal_hole): #clip_polygons_2d
			carved_polygons.append(new_polygon)
	
	# Take care of collision layer and mask.
	var collider = create_collider(carved_polygons)
	match portal_type:
		PortalType.BLUE_PORTAL: collider.set_collision_layer(Layers.BLUE_INNER)
		PortalType.ORANGE_PORTAL: collider.set_collision_layer(Layers.ORANGE_INNER)
	
	# create new collider from polygons
	add_child(collider)
	static_collider = collider

func _physics_process(delta):
	if (linked_portal == null): return
	
	var overlapped_bodies = inner_area.get_overlapping_bodies()
	if (overlapped_bodies.size() < 1): return
	
	var N = Vector2(-1,0).rotated(global_transform.get_rotation()) # Portal normal
	var O = global_transform.get_origin() # Portal Origin
	var D = N.dot(O) # Distance from the origin
	
	# Invert polarity of the plane
	N = -N
	D = -D
	
	for overlapped_body in overlapped_bodies:
		# This is the distance from the plane of the portal to the origin of the body
		var distance = N.dot(overlapped_body.global_transform.get_origin()) - D
		print(overlapped_body.global_transform.get_origin())
		if (distance < 0):
			teleport(overlapped_body)

func teleport(body):
	var new_transform = body.get_transform()
	new_transform.origin = linked_portal.global_transform.get_origin()
	body.set_transform(new_transform)

func reset_portal():
	if (static_collider != null):
		remove_child(static_collider)
	static_collider = null

func create_collider(polygons: Array) -> StaticBody2D:
	var colliderArea2D = StaticBody2D.new()
	
	for polygon in polygons:
		var collider = CollisionPolygon2D.new()
		collider.polygon = polygon
		colliderArea2D.add_child(collider)
	
	return colliderArea2D

func enter_outer_area(body):
	if (linked_portal == null): return
	match portal_type:
		PortalType.BLUE_PORTAL:
			body.set_collision_layer_bit(Layers.BLUE_INNER, true)
			body.set_collision_layer_bit(Layers.BLUE_OUTER, true)
			body.set_collision_mask_bit(Layers.BLUE_INNER, true)
			body.set_collision_mask_bit(Layers.BLUE_OUTER, true)
		PortalType.ORANGE_PORTAL:
			body.set_collision_layer_bit(Layers.ORANGE_INNER, true)
			body.set_collision_layer_bit(Layers.ORANGE_OUTER, true)
			body.set_collision_mask_bit(Layers.ORANGE_INNER, true)
			body.set_collision_mask_bit(Layers.ORANGE_OUTER, true)

func leave_outer_area(body):
	if (linked_portal == null): return
	match portal_type:
		PortalType.BLUE_PORTAL:
			body.set_collision_layer_bit(Layers.BLUE_INNER, false)
			body.set_collision_layer_bit(Layers.BLUE_OUTER, false)
			body.set_collision_mask_bit(Layers.BLUE_INNER, false)
			body.set_collision_mask_bit(Layers.BLUE_OUTER, false)
		PortalType.ORANGE_PORTAL:
			body.set_collision_layer_bit(Layers.ORANGE_INNER, false)
			body.set_collision_layer_bit(Layers.ORANGE_OUTER, false)
			body.set_collision_mask_bit(Layers.ORANGE_INNER, false)
			body.set_collision_mask_bit(Layers.ORANGE_OUTER, false)

func enter_inner_area(body):
	if (linked_portal == null): return
	body.set_collision_layer_bit(Layers.FLOOR, false)
	body.set_collision_mask_bit(Layers.FLOOR, false)

func leave_inner_area(body):
	if (linked_portal == null): return
	body.set_collision_layer_bit(Layers.FLOOR, true)
	body.set_collision_mask_bit(Layers.FLOOR, true)
