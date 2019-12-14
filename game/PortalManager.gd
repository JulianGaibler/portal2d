extends Node

var blue_portal = null
var blue_portal_fixed = false
var orange_portal = null
var orange_portal_fixed = false


func register_portal(new_portal, fixed = false):
    match new_portal.type:
        0:
            if (blue_portal != null): blue_portal.close_portal()
            blue_portal = new_portal
            blue_portal_fixed = fixed
        1:
            if (orange_portal != null): orange_portal.close_portal()
            orange_portal = new_portal
            orange_portal_fixed = fixed
    
    if (blue_portal != null): blue_portal.link_portal(orange_portal)
    if (orange_portal != null): orange_portal.link_portal(blue_portal)
    

func close_portals():
    if (blue_portal != null and not blue_portal_fixed):
        blue_portal.close_portal()
        blue_portal = null
    if (orange_portal != null and not orange_portal_fixed):
        orange_portal.close_portal()
        orange_portal = null
