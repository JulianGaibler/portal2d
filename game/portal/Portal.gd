extends Node2D

## Imports ##

const Layers = preload("res://Layers.gd").Layers
enum PortalType {BLUE_PORTAL = 0, ORANGE_PORTAL = 1}
enum PortalOrientation {UP = 0, DOWN = 1}
const portal_hole = PoolVector2Array([Vector2(-96, 128), Vector2(-96, -128), Vector2(32, -128), Vector2(32, 128)])


## Exported Variabled ##

export(PortalType) var type = PortalType.BLUE_PORTAL
export(PortalOrientation) var orientation = PortalOrientation.UP

## Internal Variabled ##

# Reference to static collider, created by portal
var static_collider = null
# Reference to the linked portal
var linked_portal = null
# Polygons from ScanArea in world-space
var collider_polygons = []
# Reference to outer detection area
var outer_area
# Reference to inner detection area
var inner_area
# Normal vector of this portal, pointing away from the entrance
var normal_vec
# Direction Vector of the portal, pointing where up is
var direction_vec



func _ready():
    normal_vec = Vector2.RIGHT.rotated(global_rotation)
    direction_vec = (Vector2.UP if orientation == PortalOrientation.UP else Vector2.DOWN).rotated(global_rotation)
    
    outer_area = get_node("OuterArea")
    inner_area = get_node("InnerArea")
    
    outer_area.connect("body_exited", self, "leave_outer_area")
    inner_area.connect("body_exited", self, "leave_inner_area")
    inner_area.connect("body_entered", self, "enter_inner_area")
    outer_area.connect("body_entered", self, "enter_outer_area")
    
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
    match type:
        PortalType.BLUE_PORTAL: collider.set_collision_layer(Layers.BLUE_INNER)
        PortalType.ORANGE_PORTAL: collider.set_collision_layer(Layers.ORANGE_INNER)
    
    # create new collider from polygons
    add_child(collider)
    static_collider = collider


func create_collider(polygons: Array) -> StaticBody2D:
    var colliderArea2D = StaticBody2D.new()
    
    for polygon in polygons:
        var collider = CollisionPolygon2D.new()
        collider.polygon = polygon
        colliderArea2D.add_child(collider)
    
    return colliderArea2D


func _draw():
    draw_line(Vector2(0,0), Vector2(1,0) * 64, Color.white)
    
    var nr = Vector2(1,0).rotated(deg2rad(90))
    draw_line(nr * 128, nr * -128, Color.white)
    
    draw_circle(Vector2(0,0), 10, (Color.blue if type == PortalType.BLUE_PORTAL else Color.orange))
    draw_circle((Vector2(0,-1) if orientation == PortalOrientation.UP else Vector2(0,1)) * 128, 5, (Color.blue if type == PortalType.BLUE_PORTAL else Color.orange))


func _physics_process(delta):
    if (linked_portal == null): return
    
    var overlapped_bodies = inner_area.get_overlapping_bodies()
    if (overlapped_bodies.size() < 1): return
    
    var q = normal_vec
    var p = global_position # Portal Origin
    
    for overlapped_body in overlapped_bodies:
        # This is the distance from the plane of the portal to the origin of the body
        var a = overlapped_body.global_position
        var d = p.dot(q)
        
        var distance = -((d - a.dot(q)) / q.length())
        
        if (distance < 0): # and distance > -32
            teleport(overlapped_body)


func teleport(body):
    # Create Basis transformation matrix from this to the linked portal
    var from = Matrix2D.new(direction_vec.x, direction_vec.y, normal_vec.x, normal_vec.y)
    var to = Matrix2D.new(linked_portal.direction_vec.x, linked_portal.direction_vec.y, linked_portal.normal_vec.x, linked_portal.normal_vec.y)
    var tf = to.inverse().multiply_mat(from)
    
    # Transform velocity
    body.linear_velocity = (tf.multiply_vec(body.linear_velocity)).bounce(linked_portal.normal_vec)
    
    # Transform position
    var po = body.global_position - global_position
    var new_pos = linked_portal.global_position + (tf.multiply_vec(po).bounce(linked_portal.normal_vec))
    body.global_transform.origin = new_pos


func close_portal():
    get_parent().remove_child(self)


func reset_portal():
    if (static_collider != null):
        remove_child(static_collider)
    static_collider = null


func enter_outer_area(body):
    if (linked_portal == null): return
    match type:
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
    match type:
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
    match type:
        PortalType.BLUE_PORTAL:
            if body.get_collision_layer_bit(Layers.ORANGE_INNER): return
        PortalType.ORANGE_PORTAL:
            if body.get_collision_layer_bit(Layers.BLUE_INNER): return
    body.set_collision_layer_bit(Layers.FLOOR, true)
    body.set_collision_mask_bit(Layers.FLOOR, true)
