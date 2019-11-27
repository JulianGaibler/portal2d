extends Node2D

const NUMBER_DISTANCE = 192
const PROGRESS_DISTANCE = 8
const ICONS_DISTANCE = 112
enum SIGN_TYPES {
    cube_drop = 0,
    cube_bonk = 1,
    laser_cube = 2,
    laser_power = 3,
    portal_fling = 4,
    portal_fling_2 = 5,
    drink_water = 6,
    goop = 7,
    Turrets = 8,
    bridge_block = 9,
    turret_burn = 10,
    button_stand = 11,
    cube_button = 12,
    tbeams = 13,
    plate_fling = 14,
    bridges = 15,
}

onready var animation_player := $AnimationPlayer
onready var number1 := $Overlay/Number/First
onready var number2 := $Overlay/Number/Second
onready var progress_bar := $Overlay/Progress/Bar
onready var progress_text := $Overlay/Progress/Text
onready var icons_node := $Overlay/Icons

export(bool) var start_on = true
export(int) var number = 0
export(int) var max_number = 19
export(Array, SIGN_TYPES) var icons_type
export(Array, bool) var icons_on

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
    
    for i in range(icons_type.size()):
        var child = icons_node.get_child(i)
        if icons_on[i]:
             child.modulate = Color.white
        child.region_rect.position.x = icons_type[i] * ICONS_DISTANCE


    if start_on:
        turn_on()
    else:
        animation_player.play("BindPose")
            
func turn_on():
    animation_player.play("flicker-on")
