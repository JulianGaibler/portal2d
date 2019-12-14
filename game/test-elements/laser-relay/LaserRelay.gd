extends Area2D

onready var animation_player := $AnimationPlayer

enum actions {ON, OFF}

signal activated
signal deactivated

var lasers_in_area = 0

var active = false
var action = actions.ON
var timeout = null

func _ready():
    connect("body_exited", self, "leave_area")
    connect("body_entered", self, "enter_area")

func _process(delta):
    if timeout == null: return
    timeout -= delta

    if timeout < 0.0:
        timeout = null
        match action:
            actions.ON:
                if lasers_in_area < 1 || active: return
                emit_signal("activated")
                active = true
                animation_player.play("rotating_start")
                animation_player.queue("rotating")
            actions.OFF:
                if lasers_in_area > 0 || !active: return
                emit_signal("deactivated")
                active = false
                animation_player.play("rotating_end")
                animation_player.queue("BindPose")

func leave_area(body):
    lasers_in_area -= 1
    if lasers_in_area == 0:
        timeout = .5
        action = actions.OFF

func enter_area(body):
    lasers_in_area += 1
    if lasers_in_area == 1:
        timeout = .5
        action = actions.ON
