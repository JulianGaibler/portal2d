extends Node2D

func set_on():
    for n in get_children():
        n.set_on()

func set_off():
    for n in get_children():
        n.set_off()
