extends Sprite

export(bool) var on = false
onready var texture_off = texture
export(Texture) var texture_on

func set_on():
    texture = texture_on

func set_off():
    texture = texture_off
