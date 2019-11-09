extends Node

var blue_portal = null
var orange_portal = null

func register_portal(new_portal):
    match new_portal.type:
        0:
            if (blue_portal != null): blue_portal.close_portal()
            blue_portal = new_portal
        1:
            if (orange_portal != null): blue_portal.close_portal()
            orange_portal = new_portal
    if (blue_portal != null): blue_portal.link_portal(orange_portal)
    if (orange_portal != null): orange_portal.link_portal(blue_portal)
    

func close_portals():
    if (blue_portal != null): blue_portal.close_portal()
    if (orange_portal != null): orange_portal.close_portal()
