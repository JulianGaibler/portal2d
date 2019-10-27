extends Camera2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
        
func _input(event):
    if event.is_action_pressed("zoom_in"):
        zoom_in()
        
    if event.is_action_pressed("zoom_out"):
        zoom_out()

func zoom_in():
        var current_zoom = get_zoom()
        current_zoom.x -= 1
        current_zoom.y -= 1        
        if current_zoom.x < 1:
            current_zoom.x = 1
            current_zoom.y = 1
        set_zoom(current_zoom)
        
func zoom_out():
        var current_zoom = get_zoom()
        current_zoom.x += 1
        current_zoom.y += 1           
        if current_zoom.x > 5:
            current_zoom.x = 5
            current_zoom.y = 5
             
        set_zoom(current_zoom)
