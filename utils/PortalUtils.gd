class_name PortalUtils

const BinaryLayers = preload("res://Layers.gd").BinaryLayers

# This is a wrapper for the intersect_ray function of Physics2DDirectSpaceState with portal awareness.
# If a ray intersects with a portal, it will be recast on the other one. Hence an array of intersections is retunred.
# Note: The field 'from' will be added to each intersection, so that we know the origin of the subsequent casts.
static func intersect_ray(space_state: Physics2DDirectSpaceState, from: Vector2, to: Vector2, exclude: Array = [ ],
                          collision_layer: int = 2147483647, collide_with_bodies: bool = true, collide_with_areas: bool = false) -> Array:
    var results = []

    while true:
        # Cast a ray
        var r = space_state.intersect_ray(from, to, exclude, collision_layer | BinaryLayers.WHITE, collide_with_bodies, collide_with_areas)
        # If the ray did not hit anything: break
        if r.empty():
            r.empty = true
            r.from = from
            results.append(r)
            break
        r.empty = false
        # Add from (because you won't know it with portals)
        r.from = from

        # If this collision did not hit a portal break
        if !r.collider.has_meta("portal_type"):
            r.portal = null
            results.append(r)
            break
        # Otherwise, transform from and to and do it again
        else:
            r.portal = r.collider.get_parent()
            results.append(r)
            # Transforming
            var transformed = r.collider.get_parent().teleport_vector(r.position, to - r.position)
            if transformed == null: break
            from = transformed[0] + r.collider.get_parent().linked_portal.get_ref().normal_vec
            # The ray needs to be shortened, to be realistic and avoid endless collisions
            var shortened = transformed[1] * (1 - from.distance_to(to) / transformed[1].length())
            to = transformed[1] + from

    return results
