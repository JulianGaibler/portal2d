extends Control

export(bool) var pause_menu = false

onready var node_main := $Main
onready var node_pause := $Pause
onready var node_levels := $Levels
onready var node_settings := $Settings

signal change_menu
signal exit_menu
signal resume_game

var levels = {
    "Introduction": "res://test-chambers/level_a1.tscn",
    "Portal Gun": "res://test-chambers/level_a2.tscn",
    "Cubes & Portals": "res://test-chambers/level_a3.tscn",
    "Cube Momentum": "res://test-chambers/level_a4.tscn",
    "Player Momentum": "res://test-chambers/level_a5.tscn",
    "Laser Intro": "res://test-chambers/level_b1.tscn",
    "Catapult Intro": "res://test-chambers/level_b2.tscn",
    "Bridge Intro": "res://test-chambers/level_b3.tscn",
    "Turret Intro": "res://test-chambers/level_b4.tscn",
    "Funnel Intro": "res://test-chambers/level_b5.tscn",
}

func _ready():
    show_menu(0, true)
    # Main
    $Main/VBoxContainer/Button1.connect("pressed", self, "start_game")
    $Main/VBoxContainer/Button2.connect("pressed", self, "show_menu", [1])
    $Main/VBoxContainer/Button3.connect("pressed", self, "show_menu", [2])
    $Main/VBoxContainer/Button4.connect("pressed", self, "exit_game")

    # Main
    $Pause/VBoxContainer/Button1.connect("pressed", self, "resume_game")
    $Pause/VBoxContainer/Button2.connect("pressed", self, "reload_level")
    $Pause/VBoxContainer/Button3.connect("pressed", self, "show_menu", [2])
    $Pause/VBoxContainer/Button4.connect("pressed", self, "load_mainmenu")

    # Levels
    $Levels/HBoxContainer/BackButton.connect("pressed", self, "show_menu", [0])
    var vbox = $Levels/HBoxContainer/Control/ScrollContainer/MarginContainer/VBoxContainer
    for key in levels:
        var b = Button.new()
        b.text = key
        b.align = Button.ALIGN_LEFT
        b.connect("pressed", self, "load_level", [levels[key]])
        vbox.add_child(b)
    
    # Settings
    $Settings/HBoxContainer/BackButton.connect("pressed", self, "show_menu", [0])

func start_game():
    Game.goto_scene_fade("res://test-chambers/level_a1.tscn")
    emit_signal("exit_menu")

func load_level(path: String):
    Game.goto_scene_fade(path)
    emit_signal("exit_menu")

func load_mainmenu():
    Game.goto_scene_fade("res://menus/MainMenu.tscn")
    emit_signal("exit_menu")

func resume_game():
    emit_signal("resume_game")

func reload_level():
    Game.reload_scene()
    emit_signal("exit_menu")

func show_menu(index: int, silent: bool = false):
    if !silent: emit_signal("change_menu")
    node_main.visible = index == 0 and not pause_menu
    node_pause.visible = index == 0 and pause_menu
    node_levels.visible = index == 1
    node_settings.visible = index == 2

func exit_game():
    get_tree().quit()
