extends Node

signal activate
signal deactivate

var a = false
var b = false
var o = false

func set_a(a: bool):
    self.a = a
    _check()

func set_b(b: bool):
    self.b = b
    _check()
    
func _check():
    if (a and b) != o:
        o = a and b
        if o: emit_signal("activate")
        else: emit_signal("deactivate")
