extends Node2D

const PortalType = preload("res://portal/Portal.gd").PortalType
const PortalOrientation = preload("res://portal/Portal.gd").PortalOrientation
const Portal = preload("res://portal/Portal.tscn")

export(bool) var start_activated = false
export(PortalType) var type = PortalType.BLUE_PORTAL
export(PortalOrientation) var orientation = PortalOrientation.UP

func _ready():
    if !start_activated: return
    activate()
    
func activate():
    var instance = Portal.instance()
    add_child(instance)
    instance.position += Vector2.ZERO
    instance.initiate(type, orientation, true)
