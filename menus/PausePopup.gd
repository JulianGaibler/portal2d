extends ColorRect

onready var sign_flicker_audio := $TestchamberSign/FlickerAudio
onready var sign_animation_player := $TestchamberSign/AnimationPlayer

func _ready():
    self.hide()

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if Game.is_in_main_menu(): return
        if(get_tree().paused == false): pause_game()
        else: resume_Game()
        

func pause_game():
    flicker_change()
    get_tree().paused = true
    self.show()

func resume_Game():
    sign_flicker_audio.stop()
    get_tree().paused = false
    self.hide()

func flicker_change():
    sign_animation_player.play("flicker_change")
    sign_flicker_audio.play(1.0)

func menu_off():
    resume_Game()
    sign_animation_player.play("flicker-off")
    sign_flicker_audio.play(1.5)
