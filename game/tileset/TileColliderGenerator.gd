extends TileMap

const BinaryLayers = preload("res://Layers.gd").BinaryLayers

func _ready():
    var normal = create_static_collider()
    var white = create_static_collider()
    white.add_to_group("white_layer")
    
    for cell_coords in get_used_cells():
        var cell_id = get_cell(cell_coords.x, cell_coords.y)
        
        for shape_id in range(tile_set.tile_get_shape_count(cell_id)):
            var shape = tile_set.tile_get_shape(cell_id, shape_id)
            var polygon_a = PolygonUtils.shape_to_polygon(shape.get_rid())
            var polygon_b = PolygonUtils.move_polygon(polygon_a, cell_size * cell_coords)
            
            var polygon_shape = ConvexPolygonShape2D.new()
            polygon_shape.set_point_cloud(polygon_b)
            var collider = CollisionShape2D.new()
            collider.shape = polygon_shape
            
            var first_char = tile_set.tile_get_name(cell_id)[0]
            
            if first_char == "a" or first_char == "x": white.add_child(collider)
            else: normal.add_child(collider)
    
    add_child(normal)
    add_child(white)
            
func create_static_collider() -> StaticBody2D:
    var colliderStaticBody2D = StaticBody2D.new()
    colliderStaticBody2D.collision_layer = BinaryLayers.FLOOR
    return colliderStaticBody2D
