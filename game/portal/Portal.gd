extends Node2D

#### Enums ####
##
const Layers = preload("res://Layers.gd").Layers
const BinaryLayers = preload("res://Layers.gd").BinaryLayers
enum PortalType {BLUE_PORTAL = 0, ORANGE_PORTAL = 1}
enum PortalOrientation {UP = 0, DOWN = 1}

#### Constants ####
##
# This is the hole that gets cut into the geometry
const portal_hole = PoolVector2Array([Vector2(-96, 128), Vector2(-96, -128), Vector2(1, -128), Vector2(1, 128)])


## Exported Variabled ##
##
export(PortalType) var type = PortalType.BLUE_PORTAL
export(PortalOrientation) var orientation = PortalOrientation.UP

## Internal Variabled ##
##
# Reference to colliders created by the portal
var static_collider = null
var physics_shadows = Dictionary()
# Reference to the linked portal
var linked_portal = null
# Polygons from ScanArea in world-space with carved out hole for portal
var collider_polygons = []
# Reference areas around the portal
var outer_area
var inner_area
var scan_area
# Normal vector of this portal, pointing away from the entrance in global space
var normal_vec
# Direction Vector of the portal, pointing where up is in global space
var direction_vec
# Basis transformation matrix from this to the linked portal
var transfomration_matrix

# This function has to be called after the portal has been placed in the world
func initiate(type, orientation):
    self.type = type
    self.orientation = orientation
    
    # Calculate direction- and normal-vector
    normal_vec = Vector2.RIGHT.rotated(global_rotation)
    direction_vec = (Vector2.UP if orientation == PortalOrientation.UP else Vector2.DOWN).rotated(global_rotation)
    
    outer_area = get_node("OuterArea")
    inner_area = get_node("InnerArea")
    scan_area = get_node("ScanArea")
    
    # This will let portal-aware raycasts know they collided with a portal
    get_node("PortalLine").set_meta("isPortal",1)
    
    # Hook up signals from the trigger-areas with functions
    outer_area.connect("body_exited", self, "leave_outer_area")
    inner_area.connect("body_exited", self, "leave_inner_area")
    inner_area.connect("body_entered", self, "enter_inner_area")
    outer_area.connect("body_entered", self, "enter_outer_area")

    # Wait (twice for some reason) until all collisions have been calculated
    yield( get_tree(), "idle_frame" )
    yield( get_tree(), "idle_frame" )

    # Get all static colliders within ScanArea as polygons,
    # put them into local coordinates and carve a hole for the portal
    for polygon in calculate_polygon():
        var polygon2 = PolygonUtils.transform_polygon(polygon, global_transform.inverse())
        for new_polygon in Geometry.clip_polygons_2d(polygon2, portal_hole): #clip_polygons_2d
            collider_polygons.append(new_polygon)
    
    # Register newly created portal with the PortalManager
    PortalManager.register_portal(self)

# This function get's called by the PortalManager to link or unlink the portal
func link_portal(new_portal):
    # Delete all colliders and the tf-matrix
    reset_portal()
    linked_portal = new_portal
    # If there is no new portal to link to, just stay closed
    if (new_portal == null): return
    
    # This basis transformation matrix transforms from this portals basis into the one of the linked portal.
    var from = Matrix2D.new(direction_vec.x, direction_vec.y, normal_vec.x, normal_vec.y)
    var to = Matrix2D.new(linked_portal.direction_vec.x, linked_portal.direction_vec.y, linked_portal.normal_vec.x, linked_portal.normal_vec.y)
    transfomration_matrix = to.inverse().multiply_mat(from)

    var carved_polygons = [] + collider_polygons

    # In addition to the local colliders that are copied in front of our portal, we also want to take
    # those from the other portal and place them behind ours in order to avoid collision glitches.
    for polygon in linked_portal.collider_polygons:
        var newVec = PoolVector2Array()
        newVec.resize(polygon.size())
        for i in range(0, polygon.size()):
            var new_pos = polygon[i].bounce(Vector2.RIGHT)
            if (orientation != linked_portal.orientation):
                new_pos = new_pos.bounce(Vector2.UP)
            newVec.set(i, new_pos)
        carved_polygons.append(newVec)

    # Create new static collider from our polygons
    var collider = create_static_collider(carved_polygons)
    # Set collision layers of them accordingly
    match type:
        PortalType.BLUE_PORTAL: collider.set_collision_layer(BinaryLayers.BLUE_INNER)
        PortalType.ORANGE_PORTAL: collider.set_collision_layer(BinaryLayers.ORANGE_INNER)
    
    # Add the collider as child and keep a reference to it
    add_child(collider)
    static_collider = collider
    
    # The enter/exit-signals of players or objects have been ignored so far,
    # that's why we need to call the signal-handlers manually.
    for body in outer_area.get_overlapping_bodies(): enter_outer_area(body)
    for body in inner_area.get_overlapping_bodies(): enter_inner_area(body)

func _draw():
    draw_line(Vector2(0,0), Vector2(1,0) * 64, Color.white)
    
    var nr = Vector2(1,0).rotated(deg2rad(90))
    draw_line(nr * 128, nr * -128, Color.white)
    
    draw_circle(Vector2(0,0), 10, (Color.blue if type == PortalType.BLUE_PORTAL else Color.orange))
    draw_circle((Vector2(0,-1) if orientation == PortalOrientation.UP else Vector2(0,1)) * 128, 5, (Color.blue if type == PortalType.BLUE_PORTAL else Color.orange))


func _physics_process(delta):
    if (linked_portal == null): return
    
    # Physics shadows are the copied colliders of dynamic-props or the player.
    # Their positions needs to be updated with every physics-update
    for collider in physics_shadows.values():
        var rotation = collider[0].global_transform.get_rotation()
        
        # Transform position
        var po = collider[0].global_position - global_position
        var new_pos = linked_portal.global_position + (transfomration_matrix.multiply_vec(po).bounce(linked_portal.normal_vec))
        collider[1].global_transform = Transform2D()
        collider[1].global_transform.origin = new_pos
        
        var a1 = Vector2.UP.angle_to(transfomration_matrix.multiply_vec(Vector2.UP.rotated(rotation)).bounce(linked_portal.normal_vec))
        collider[1].rotate(a1)
    
    var overlapped_bodies = inner_area.get_overlapping_bodies()
    if (overlapped_bodies.size() < 1): return
    
    # Check the distance of every overlapping body except physics-shadows
    for overlapped_body in overlapped_bodies:
        if overlapped_body.is_in_group("physics-shadow"): continue
        
        var a = overlapped_body.global_position
        var d = global_position.dot(normal_vec)
        # This is the distance from the plane of the portal to the origin of the body
        var distance = -((d - a.dot(normal_vec)) / normal_vec.length())
        # If player/object is behind the portal (but not too far away), teleport them/it
        if (distance < 0 and distance > -32):
            teleport(overlapped_body)
                


func teleport(body):
    var body_rotation = body.global_transform.get_rotation()
    var transformed = teleport_vector(body.global_position, body.linear_velocity)

    # Transform velocity
    body.linear_velocity = transformed[1]
    var l = body.linear_velocity.y * linked_portal.normal_vec.y
    if (l < 400):
        body.linear_velocity.y += linked_portal.normal_vec.y * (420-l)
    
    body.global_transform = Transform2D()
    body.global_transform.origin = transformed[0]
    
    var a1 = Vector2.UP.angle_to(transfomration_matrix.multiply_vec(Vector2.UP.rotated(body_rotation)).bounce(linked_portal.normal_vec))
    body.rotate(a1)


func teleport_vector(position, direction):
    if (linked_portal == null): return null
    
    # Transform velocity
    direction = (transfomration_matrix.multiply_vec(direction)).bounce(linked_portal.normal_vec)
    
    # Transform position
    var po = position - global_position
    var new_pos = linked_portal.global_position + (transfomration_matrix.multiply_vec(po).bounce(linked_portal.normal_vec))
    
    return [new_pos, direction]


func close_portal():
    reset_portal()
    outer_area.disconnect("body_exited", self, "leave_outer_area")
    inner_area.disconnect("body_exited", self, "leave_inner_area")
    inner_area.disconnect("body_entered", self, "enter_inner_area")
    outer_area.disconnect("body_entered", self, "enter_outer_area")
    for body in inner_area.get_overlapping_bodies(): leave_inner_area(body)
    for body in outer_area.get_overlapping_bodies(): leave_outer_area(body)
    get_parent().remove_child(self)


func reset_portal():
    for collider in physics_shadows.values():
        remove_child(collider[1])
    transfomration_matrix = null
    if (static_collider != null):
        remove_child(static_collider)
    static_collider = null


func enter_outer_area(body):
    if (linked_portal == null): return
    if body.is_in_group("physics-shadow"): return
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
    if body.is_in_group("physics-shadow"): return
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
    if body.is_in_group("physics-shadow"): return
    add_shadow_body(body)
    body.set_collision_layer_bit(Layers.FLOOR, false)
    body.set_collision_mask_bit(Layers.FLOOR, false)


func leave_inner_area(body):
    if (linked_portal == null): return
    if body.is_in_group("physics-shadow"): return
    remove_shadow_body(body)
    match type:
        PortalType.BLUE_PORTAL:
            if body.get_collision_layer_bit(Layers.ORANGE_INNER): return
        PortalType.ORANGE_PORTAL:
            if body.get_collision_layer_bit(Layers.BLUE_INNER): return
    body.set_collision_layer_bit(Layers.FLOOR, true)
    body.set_collision_mask_bit(Layers.FLOOR, true)


#### Inner Body Management ####
##

# This function adds clones of dynamic-props to the physics_shadows list
func add_shadow_body(body):
    if body.is_in_group("physics-shadow"): return
    
    var shapes = []
    for child in body.get_children():
        if (child is CollisionShape2D):
            shapes.append(child.duplicate())
    if (shapes.size() > 0):
        var collider = create_kinematic_collider(shapes)        
        collider.set_script(preload("res://portal/PhysicsShadow.gd"))
        collider.parent = body
        collider.matrix = transfomration_matrix
        collider.linked_normal = linked_portal.normal_vec
        collider.add_to_group("physics-shadow")
        collider.set_collision_mask(0)
        match type:
            PortalType.BLUE_PORTAL: collider.set_collision_layer(BinaryLayers.ORANGE_INNER)
            PortalType.ORANGE_PORTAL: collider.set_collision_layer(BinaryLayers.BLUE_INNER)
        body.add_collision_exception_with(collider)
        add_child(collider)
        physics_shadows[body.get_rid()] = [body, collider]

# Removed physics-shadows from physics_shadows list
func remove_shadow_body(body):
    if body.is_in_group("physics-shadow"): return
    var collider = physics_shadows[body.get_rid()][1]
    body.remove_collision_exception_with(collider)
    remove_child(collider)
    physics_shadows.erase(body.get_rid())


# Scans the Area around the portal for static colliders and converts them into polygons
# IMPORTANT: PolygonUtils.transform_polygon can only handle some shapes and will ignore others.
func calculate_polygon():
    var polygons = []
    
    for overlapped_body in scan_area.get_overlapping_bodies():
        if !(overlapped_body is StaticBody2D): continue
        if overlapped_body.name == "PortalLine": continue
        var overlapped_body_rid = overlapped_body.get_rid()
        var overlapped_body_shapes_count = Physics2DServer.body_get_shape_count (overlapped_body_rid)
        var overlapped_body_tf = overlapped_body.global_transform
        
        for i in range(overlapped_body_shapes_count):
            var shapeRID = Physics2DServer.body_get_shape(overlapped_body_rid, i)
            var shape_tf = Physics2DServer.body_get_shape_transform(overlapped_body_rid, i)
            var polygon = PolygonUtils.shape_to_polygon(shapeRID)
            if (polygon == null): continue
            polygon = PolygonUtils.transform_polygon(polygon, shape_tf * overlapped_body_tf)
            polygons.append(polygon)
    

    var csRID = scan_area.get_node("CollisionShape2D").shape.get_rid()
    var outerAreaShape = PolygonUtils.shape_to_polygon(csRID)
    
    outerAreaShape = PolygonUtils.transform_polygon(outerAreaShape, scan_area.get_node("CollisionShape2D").global_transform)
    
    var new_polygons = []
    
    for polygon in polygons:
        for new_polygon in Geometry.intersect_polygons_2d(polygon, outerAreaShape):
            new_polygons.append(new_polygon)
    
    return new_polygons


#### Helpers ####
##

# Creates a static collider from an array of polygons
func create_static_collider(polygons: Array) -> StaticBody2D:
    var colliderArea2D = StaticBody2D.new()
    for polygon in polygons:
        var collider = CollisionPolygon2D.new()
        collider.polygon = polygon
        colliderArea2D.add_child(collider)
    
    return colliderArea2D

# Creates a kinematic collider from an array of polygons
func create_kinematic_collider(shapes: Array) -> KinematicBody2D:
    var colliderArea2D = KinematicBody2D.new()
    for shape in shapes:
        colliderArea2D.add_child(shape)
    
    return colliderArea2D
