extends Camera2D

## Camera Shake behavior related Variables ##
var _shake_duration = 0.0
var _shake_period_in_ms = 0.0
var _shake_amplitude = 0.0
var _shake_timer = 0.0
var _last_shake_timer = 0
var _previous_shake_position_x = 0.0
var _previous_shake_position_y = 0.0
var _last_shake_offset = Vector2(0, 0)
# Const Variables for Shake - Earthquake
const SHAKE_DURATION_EARTHQUAKE = 2.0
const SHAKE_FREQUENCY_EARTHQUAKE = 15
const SHAKE_AMPLITUDE_EARTHQUAKE = 50
# Const Variables for Shake - PortalShot
const SHAKE_DURATION_PORTALSHOT = 0.1
const SHAKE_FREQUENCY_PORTALSHOT = 30  
const SHAKE_AMPLITUDE_PORTALSHOT = 10

# Smooth Zoom Behaviour related Variables
var smooth_zoom = 2.5
var target_zoom = 2.5

# Zoom Speed
const ZOOM_SPEED = 10

# Player Object to connect signals on
onready var Player = get_tree().get_root().get_node("World").get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
    self.smoothing_enabled = true
    self.smoothing_speed = 1
    set_zoom(Vector2 (target_zoom, target_zoom))
    self.position = Vector2 (0,0)  
    
    if(Player != null):
        Player.connect("camera_fired_portal", self, "shake_PortalShot")
    
    pass # Replace with function body.    
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):    
    smoothing_behaviour(delta)    
    shaking_behaviour(delta)    
    pass    
        
# Input Events
func _input(event):
    if event.is_action_pressed("zoom_in"):
        zoom_in()
        
    if event.is_action_pressed("zoom_out"):
        zoom_out()
        
    if event.is_action_pressed("shake_camera_portalshot"):
        shake_camera(SHAKE_DURATION_PORTALSHOT, SHAKE_FREQUENCY_PORTALSHOT, SHAKE_AMPLITUDE_PORTALSHOT)
        
    if event.is_action_pressed("shake_camera_earthquake"):
        shake_camera(SHAKE_DURATION_EARTHQUAKE, SHAKE_FREQUENCY_EARTHQUAKE, SHAKE_AMPLITUDE_EARTHQUAKE)
        
# Camera2D Screen Shake Extension
# Checks, if Shake-Timer is set
# Randomly creates new Offset Positions for the Camera until Timer is set back to zero
func shaking_behaviour(delta):
    # Only shake when there's shake time remaining.
    if _shake_timer == 0:
        return
    # Only shake on certain frames.
    _last_shake_timer = _last_shake_timer + delta
    # Be mathematically correct in the face of lag; usually only happens once.
    while _last_shake_timer >= _shake_period_in_ms:
        _last_shake_timer = _last_shake_timer - _shake_period_in_ms
        # Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
        var intensity = _shake_amplitude * (1 - ((_shake_duration - _shake_timer) / _shake_duration))
        # Noise calculation logic from http://jonny.morrill.me/blog/view/14
        var new_x = rand_range(-1.0, 1.0)
        var x_component = intensity * (_previous_shake_position_x + (delta * (new_x - _previous_shake_position_x)))
        var new_y = rand_range(-1.0, 1.0)
        var y_component = intensity * (_previous_shake_position_y + (delta * (new_y - _previous_shake_position_y)))
        _previous_shake_position_x = new_x
        _previous_shake_position_y = new_y
        # Track how much we've moved the offset, as opposed to other effects.
        var new_offset = Vector2(x_component, y_component)
        set_offset(get_offset() - _last_shake_offset + new_offset)
        _last_shake_offset = new_offset
        self.position = new_offset
    # Reset the offset when we're done shaking.
    _shake_timer = _shake_timer - delta
    if _shake_timer <= 0:
        _shake_timer = 0
        set_offset(get_offset() - _last_shake_offset)

func shake_Earthquake():
    shake_camera(SHAKE_DURATION_EARTHQUAKE, SHAKE_FREQUENCY_EARTHQUAKE, SHAKE_AMPLITUDE_EARTHQUAKE)
    
func shake_PortalShot():
    print("Poralshot signal detected")
    shake_camera(SHAKE_DURATION_PORTALSHOT, SHAKE_FREQUENCY_PORTALSHOT, SHAKE_AMPLITUDE_PORTALSHOT)

# Triggers the Camera Shake behaviour by setting the Shake_Timer and other shaking related values
func shake_camera(duration, frequency, amplitude):
    _shake_duration = duration
    _shake_timer = duration
    _shake_period_in_ms = 1.0 / frequency
    _shake_amplitude = amplitude
    _previous_shake_position_x = rand_range(-1.0, 1.0)
    _previous_shake_position_y = rand_range(-1.0, 1.0)
    # Reset previous offset, if any.
    set_offset(get_offset() - _last_shake_offset)
    _last_shake_offset = Vector2(0, 0)

# Defines how smooth the camera is following it's parent Node (Player)
func smoothing_behaviour(delta):
    smooth_zoom = lerp(smooth_zoom, target_zoom, ZOOM_SPEED * delta)
    if smooth_zoom != target_zoom:
        set_zoom(Vector2 (smooth_zoom, smooth_zoom))

# Zoom Camera OUT
func zoom_out():
    target_zoom += 1    
    if(target_zoom > 5): 
        target_zoom = 5
        
# Zoom Camera IN
func zoom_in():
    target_zoom -= 1    
    if(target_zoom < 1): 
        target_zoom  = 1
