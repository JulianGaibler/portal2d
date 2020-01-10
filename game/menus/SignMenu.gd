extends Control

onready var node_main := $Main
onready var node_levels := $Levels
onready var node_settings := $Settings

signal change_menu
signal exit_menu

func _ready():
    # Main
    $Main/VBoxContainer/Button1.connect("pressed", self, "start_game")
    $Main/VBoxContainer/Button2.connect("pressed", self, "show_menu", [1])
    $Main/VBoxContainer/Button3.connect("pressed", self, "show_menu", [2])
    $Main/VBoxContainer/Button4.connect("pressed", self, "exit_game")
    
    # Levels
    $Levels/HBoxContainer/BackButton.connect("pressed", self, "show_menu", [0])
    
    # Settings
    $Settings/HBoxContainer/BackButton.connect("pressed", self, "show_menu", [0])

func start_game():
    Game.goto_scene_fade("res://test-chambers/level_a1.tscn")
    emit_signal("exit_menu")

func show_menu(index: int):
    emit_signal("change_menu")
    node_main.visible = index == 0
    node_levels.visible = index == 1
    node_settings.visible = index == 2

func exit_game():
    get_tree().quit()
