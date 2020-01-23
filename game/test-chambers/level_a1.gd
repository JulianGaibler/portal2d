extends Node2D

onready var spawner_panel = $SpawnerPanel
onready var spawner_orange = $PortalSpawnerOrange
onready var spawner_blue = $SpawnerPanel/PanelTransform/PortalSpawnerBlue
onready var sign_00 = $TestchamberSign00
onready var tooltip = $Tooltip_1

func _ready():
    yield(get_tree().create_timer(3), "timeout")
    sign_00.turn_on()
    tooltip.show_message()
    yield(get_tree().create_timer(1), "timeout")
    spawner_panel.play_animation("corder-90-left-out-heavy")
    yield(get_tree().create_timer(4), "timeout")
    spawner_blue.activate()
    spawner_orange.activate()

func force_close_portals():
    PortalManager.force_close_portals()
