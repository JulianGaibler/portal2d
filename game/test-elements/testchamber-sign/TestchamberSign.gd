extends Node2D

const NUMBER_DISTANCE = 192
const PROGRESS_DISTANCE = 8
const ICONS_DISTANCE = 112
const ICONS_ORDER = [0,1,5,8,4,2,6,7,3,9]

onready var animation_player := $AnimationPlayer
onready var number1 := $Overlay/Number/First
onready var number2 := $Overlay/Number/Second
onready var progress_bar := $Overlay/Progress/Bar
onready var progress_text := $Overlay/Progress/Text
onready var icons_node := $Overlay/Icons


export(bool) var start_on = true
export(int) var number = 0
export(int) var max_number = 19
export(int, FLAGS, "Cube Dropper", "Cube Hit Head", "Laser Redirect", "Laser Reciever", "Portal Jump", "Portal Fling", "No Drinking Water", "Toxic Water", "Turrets", "Turret behind Wall", "Burn Turret with Laser", "Player on Button", "Cube on Button", "Player through Funnel", "Catapult", "Light Bridge") var sign_bitflag = 0

func _ready():
    # Number
    if number < 0 || number > 99:
        number1.region_rect.position.x = NUMBER_DISTANCE * 10
        number2.region_rect.position.x = NUMBER_DISTANCE * 10
    else:
        var num_string = "%02d"%number
        number1.region_rect.position.x = NUMBER_DISTANCE * int(num_string[0])
        number2.region_rect.position.x = NUMBER_DISTANCE * int(num_string[1])
    # Progress
    progress_text.text = "%02d / %02d"%[number, max_number]
    progress_bar.region_rect.size.x = PROGRESS_DISTANCE * (0 if number < 0 else number)
    # Icons
    var sign_array = []
    for i in range(16):
        var bit_flag = 1 << i
        if sign_bitflag & bit_flag != 0:
            sign_array.push_back(i)
    
    for i in range(min(10, sign_array.size())):
        var child = icons_node.get_child(ICONS_ORDER[i])
        child.modulate = Color.white
        child.region_rect.position.x = sign_array[i] * ICONS_DISTANCE

    if start_on:
        turn_on()
    else:
        animation_player.play("BindPose")
            
func turn_on():
    animation_player.play("flicker-on")
