extends Area2D

# Returns all overlapping bodies within the area
# as an array of polygons positioned in world space.
func calculate_polygon():
	var polygons = []
	
	for overlapped_body in get_overlapping_bodies():
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
			
	return polygons
