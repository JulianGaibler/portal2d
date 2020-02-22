extends Node2D

func set_on():
    for n in get_children():
        if n.has_method("set_on"): n.set_on()

func set_off():
    for n in get_children():
        if n.has_method("set_off"): n.set_off()
