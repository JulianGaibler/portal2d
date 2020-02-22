extends Sprite

export(NodePath) var portal_gun
export(NodePath) var sprite
export(NodePath) var sound

func activate_portalgun():
    var gun = get_node(portal_gun)
    gun.visible = true
    gun.allow_primary = true
    get_node(sound).play()
    get_node(sprite).free()

func upgrade_portalgun():
    get_node(portal_gun).allow_secondary = true
    get_node(sound).play()
    get_node(sprite).free()
