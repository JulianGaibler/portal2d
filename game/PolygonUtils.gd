class_name PolygonUtils

# Transforms polygon with given Transform2D
static func transform_polygon(polygon: PoolVector2Array, tf: Transform2D) -> PoolVector2Array:
	var newVec = PoolVector2Array()
	newVec.resize(polygon.size())
	for i in range(0, polygon.size()):
		newVec.set(i, tf.xform(polygon[i]))
	return newVec


# Converts shapes into polygons
# (Everything besides rectangles and polygons will return null)
static func shape_to_polygon(shape_rid: RID): # -> PoolVector2Array
	var polygon: PoolVector2Array

	var shape_type = Physics2DServer.shape_get_type(shape_rid)
	var shape_data = Physics2DServer.shape_get_data(shape_rid)
	match shape_type:
		
		Physics2DServer.SHAPE_RECTANGLE:
			polygon = PoolVector2Array([
				Vector2(-shape_data.x, shape_data.y),
				Vector2(-shape_data.x, -shape_data.y),
				Vector2(shape_data.x, -shape_data.y),
				Vector2(shape_data.x, shape_data.y),
			])
			
		Physics2DServer.SHAPE_CONVEX_POLYGON, Physics2DServer.SHAPE_CUSTOM:
			polygon = PoolVector2Array(shape_data)
			
		_:
			return null

	return polygon
