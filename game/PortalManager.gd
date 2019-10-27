extends Node

const Portal = preload("res://portal/Portal.gd")

var blue_portal: Portal = null
var orange_portal: Portal = null

func register_portal(new_portal: Portal):

	match new_portal.portal_type:
		Portal.PortalType.BLUE_PORTAL:
			if (blue_portal != null): blue_portal.close_portal()
			blue_portal = new_portal
		Portal.PortalType.ORANGE_PORTAL:
			if (orange_portal != null): blue_portal.close_portal()
			orange_portal = new_portal
	if (blue_portal != null): blue_portal.link_portal(orange_portal)
	if (orange_portal != null): orange_portal.link_portal(blue_portal)
	

func close_portals():
	if (blue_portal != null): blue_portal.close_portal()
	if (orange_portal != null): blue_portal.close_portal()
