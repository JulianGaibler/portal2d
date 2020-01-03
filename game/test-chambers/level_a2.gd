extends Node2D

onready var portalgun = $Player/PortalGun
onready var sprite = $GunSprite

func activate_portalgun():
    portalgun.visible = true
    portalgun.allow_primary = true
    sprite.free()
