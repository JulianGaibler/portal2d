extends CanvasLayer

onready var animation_player := $AnimationPlayer
onready var rich_text := $TooltipPopup/MarginContainer/RichTextLabel
onready var popup := $TooltipPopup

export(String) var message = ""
export(float) var show_time = 6.0

var timeout = 0.0

func _ready():
    popup.visible = false
    rich_text.text = message
    set_process(false)

func show_message():
    animation_player.play("go-in")
    timeout = show_time
    set_process(true)

func _process(delta):
    timeout -= delta
    if timeout <= 0.0:
        animation_player.play("go-out")
        set_process(false)
