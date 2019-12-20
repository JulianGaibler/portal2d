extends Node2D

var button_Start
var button_Settings
var button_Exit

func _ready():
	button_Start = get_node("Background/Button_Start")
	button_Settings = get_node("Background/Button_Settings")    
	button_Exit = get_node("Background/Button_Exit")    
	
	button_Start.connect("pressed", self, "load_FirstScene")
	button_Settings.connect("pressed", self, "show_Settings") 
	button_Exit.connect("pressed", self, "exit_Game") 
	
func load_FirstScene():
	print("Loading first scene")
	Game.goto_scene("res://World.tscn")       
	
func show_Settings():
	print("Showing Settings") 
	
func exit_Game():
	get_tree().quit() 
