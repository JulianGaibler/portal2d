extends Panel

var button_Resume
var button_MainMenu
var button_ExitApplication

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    button_MainMenu = get_node("ButtonResume")
    button_MainMenu.connect("pressed", self, "resume_Game")  
      
    button_MainMenu = get_node("ButtonMainMenu")
    button_MainMenu.connect("pressed", self, "load_MainMenu")   
     
    button_MainMenu = get_node("ButtonExitGame")
    button_MainMenu.connect("pressed", self, "exit_Application")
    pass # Replace with function body.

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if(get_tree().paused == false):
            get_tree().paused = true
            self.show()
        else:
            get_tree().paused = false
            self.hide()
        

func resume_Game():
    get_tree().paused = false
    self.hide()
    
func load_MainMenu():
    get_tree().paused = false
    Game.goto_scene("res://menus/MainMenu.tscn") 
    
func exit_Application():
    get_tree().quit() 
