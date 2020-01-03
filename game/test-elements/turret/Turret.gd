extends FizzleRigidBody2D

const BinaryLayers = preload("res://Layers.gd").BinaryLayers
const PLAYER_UP = Vector2(0, -50)
const RAD_180 = deg2rad(180)

onready var floor_detection = $FloorDetection
onready var laser_node = $Laser
onready var wing_node = $Wing
onready var tracking_area = $TrackingArea
onready var animation_player = $AnimationPlayer
onready var bullet_particles = $Wing/Barrel/Bullets
onready var gun_audio = $GunAudio
onready var voice_audio = $VoiceAudio
onready var mechanics_audio = $MechanicsAudio

export(bool) var looks_right = true

enum { IDLE, ALERT, SHOOTING, SEARCHING, HELD, DYING, DEAD }


var state = IDLE
var track_player = false
var tracked_player = null
var being_held = false

var laser_node_rotation_goal = 0.0
var laser_node_rotation_time = 1.0
var wing_node_rotation_goal = 0.0
var wing_node_rotation_time = 1.0

var timeout = 0.0
var counter = 0

var has_seen_player = false

func _ready():
    tracking_area.connect("body_entered", self, "enter_area")
    tracking_area.connect("body_exited", self, "leave_area")

func enter_area(body):
    if body.is_in_group("player"):
        tracked_player = body
        track_player = true
func leave_area(body):
    if body.is_in_group("player"): track_player = false

func next_idlechat():
    timeout = rand_range(10.0, 25.0)

func _physics_process(delta):
    
    laser_node.rotation = lerp_angle(laser_node.rotation, laser_node_rotation_goal, laser_node_rotation_time * 10 * delta)
    wing_node.rotation = lerp_angle(wing_node.rotation, wing_node_rotation_goal, wing_node_rotation_time * 10 * delta)
    
    if state == DEAD: return
    elif state != HELD and being_held: go_held()
    elif state != DYING and state != HELD and is_knocked_over(): go_dying()
    
    match state:
        IDLE: do_idle(delta, tracked_player)
        ALERT: do_alert(delta, tracked_player)
        SHOOTING: do_shooting(delta, tracked_player)
        SEARCHING: do_searching(delta, tracked_player)
        HELD: do_held(delta, tracked_player)
        DYING: do_dying(delta, tracked_player)

func fizzle():
    go_dead(false)
    play_voice_audio(audio_voice_fizzler)
    .fizzle()

func play_mechanics_audio(resource):
    mechanics_audio.set_stream(resource)
    mechanics_audio.play()

func play_voice_audio(array):
    randomize()
    voice_audio.set_stream(array[randi()%array.size()])
    voice_audio.play()

### Behavior

func do_idle(delta, player):
    if has_seen_player:
        timeout -= delta
        if timeout < 0.0:
            play_voice_audio(audio_voice_idlechat)
            next_idlechat()
    if can_see_player(player): go_alert()

func do_alert(delta, player):
    timeout -= delta
    if !can_see_player(player): go_searching()
    look_at_player(player)
    if can_shoot_player(player) and timeout < 0.0: go_shooting()

func do_shooting(delta, player):
    if !can_see_player(player): go_searching()
    if !can_shoot_player(player): go_alert()
    look_at_player(player)
    var force = max(50, 400 - player.global_position.distance_to(global_position)*2)
    player.linear_velocity += (player.global_position - global_position).normalized() * force * rand_range(.4, 1.0)
    player.take_damage(100 * delta)

func do_searching(delta, player):
    timeout -= delta
    if can_see_player(player):
        go_shooting()
    elif counter == 4:
        confused_look(0.4, 1.0)
        timeout = 1.0
        counter = 3
        play_mechanics_audio(audio_mechanics_ping)
    elif timeout <= 0.0 and counter == 3:
        confused_look(-0.4, 1.0)
        timeout = 1.0
        counter = 2
    elif timeout <= 0.0 and counter == 2:
        confused_look(0.4, 1.0)
        timeout = 1.0
        counter = 1
        play_mechanics_audio(audio_mechanics_ping)
    elif timeout <= 0.0 and counter == 1:
        go_idle()

func do_held(delta, player):
    timeout -= delta
    if being_held:
        if timeout <= 0.0 and counter == 1:
            confused_look(rand_range(.1,.6), .5)
            timeout = .5
            counter = 0
            play_mechanics_audio(audio_mechanics_active)
        elif timeout <= 0.0 and counter == 0:
            confused_look(rand_range(-.6,-.1), .5)
            timeout = .5
            counter = 1
    elif can_see_player(player): go_alert()
    else: go_idle()
    
func do_dying(delta, player):
    timeout -= delta
    if timeout <= 0.0: go_dead()
    elif !is_knocked_over():
        if can_see_player(player): go_alert()
        else: go_idle()
    else:
        if timeout <= 1.5 and counter == 1:
            confused_look(-.6, 0.4)
            counter = 0

### Transitions

func go_idle():
    state = IDLE
    laser_node_rotation_goal = 0.0
    laser_node_rotation_time = 0.5
    wing_node_rotation_goal = 0.0
    wing_node_rotation_time = 0.5
    play_voice_audio(audio_voice_retire)
    animation_player.play("close")
    play_mechanics_audio(audio_mechanics_retract)
    next_idlechat()

func go_alert():
    has_seen_player = true
    gun_audio.stop()
    bullet_particles.emitting = false
    if state == IDLE:
        animation_player.play("open")
        play_mechanics_audio(audio_mechanics_active)
    play_voice_audio(audio_voice_active)
    timeout = 0.5
    state = ALERT

func go_shooting():
    gun_audio.play()
    bullet_particles.emitting = true
    state = SHOOTING

func go_searching():
    gun_audio.stop()
    play_mechanics_audio(audio_mechanics_ping)
    play_voice_audio(audio_voice_search)
    bullet_particles.emitting = false
    state = SEARCHING
    counter = 4

func go_held():
    if state == IDLE:
        animation_player.play("open")
        play_mechanics_audio(audio_mechanics_active)
    gun_audio.stop()
    play_voice_audio(audio_voice_pickup)
    bullet_particles.emitting = false
    state = HELD
    counter = 1
    timeout = 1.0

func go_dying():
    if state == IDLE:
        animation_player.play("open")
        play_mechanics_audio(audio_mechanics_active)
    gun_audio.play()
    bullet_particles.emitting = true
    timeout = 3.0
    counter = 1
    confused_look(.6, 0.4)
    state = DYING

func go_dead(stop_process = true):
    state = DEAD
    animation_player.play("close")
    play_mechanics_audio(audio_mechanics_retract)
    gun_audio.stop()
    bullet_particles.emitting = false
    confused_look(0,1)
    laser_node.deactivate()
    play_mechanics_audio(audio_mechanics_die)
    if stop_process:
        play_voice_audio(audio_voice_disabled)
        yield(get_tree().create_timer(1), "timeout")
        set_process(false)

### Helpers

func confused_look(degrees: float, time: float):
    laser_node_rotation_goal = -degrees
    laser_node_rotation_time = time
    wing_node_rotation_goal = degrees
    wing_node_rotation_time = time

func is_knocked_over() -> bool:
    return global_rotation_degrees < -80 or global_rotation_degrees > 80

func picked_up(being_held: bool):
    self.being_held = being_held

func look_at_player(player):
    if !track_player: return
    var goal = ((player.global_position+PLAYER_UP) - laser_node.global_position).angle() - global_rotation
    
    if !looks_right: goal = RAD_180 - goal if goal > 0.0 else RAD_180 + goal
    
    laser_node_rotation_goal = goal
    laser_node_rotation_time = .3
    wing_node_rotation_goal = goal
    wing_node_rotation_time = .3

func can_see_player(player) -> bool:
    if !track_player: return false
    
    var angle = rad2deg(laser_node.global_position.angle_to_point(player.global_position+PLAYER_UP)) + global_rotation_degrees

    if !looks_right: angle = 180 - angle if angle > 0.0 else 180 + angle
    
    if !((angle <= -135 and angle >= -180) or (angle <= 180 and angle >= 125)): return false
    
    var space_state = get_world_2d().direct_space_state
    var result = space_state.intersect_ray(laser_node.global_position, player.global_position+PLAYER_UP, [self] + get_tree().get_nodes_in_group("transparent"), BinaryLayers.FLOOR | BinaryLayers.BLUE_OUTER | BinaryLayers.ORANGE_OUTER)
    
    if !result.empty() and result.collider == player: return true
    return false

func can_shoot_player(player) -> bool:
    if !track_player: return false
    
    var space_state = get_world_2d().direct_space_state
    var result = space_state.intersect_ray(laser_node.global_position, player.global_position+PLAYER_UP, [self], BinaryLayers.FLOOR | BinaryLayers.BLUE_OUTER | BinaryLayers.ORANGE_OUTER)
    
    if !result.empty() and result.collider == player: return true
    return false


# SOUNDS #

# Mechanics
const audio_mechanics_active = preload("res://sounds/valve_sounds/turret_floor/active.wav")
const audio_mechanics_alert = preload("res://sounds/valve_sounds/turret_floor/alert.wav")
const audio_mechanics_die = preload("res://sounds/valve_sounds/turret_floor/die.wav")
const audio_mechanics_ping = preload("res://sounds/valve_sounds/turret_floor/ping.wav")
const audio_mechanics_retract = preload("res://sounds/valve_sounds/turret_floor/retract.wav")

# Voice
const audio_voice_fizzler = [
    preload("res://sounds/valve_sounds/turret_floor/turret_fizzler.wav"),
]

const audio_voice_active = [
    preload("res://sounds/valve_sounds/turret_floor/turret_active_1.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_active_2.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_active_3.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_active_4.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_active_5.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_active_6.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_active_7.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_active_8.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_deploy_1.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_deploy_2.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_deploy_3.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_deploy_4.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_deploy_5.wav"),
]

const audio_voice_disabled = [
    preload("res://sounds/valve_sounds/turret_floor/turret_disabled_1.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_disabled_2.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_disabled_3.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_disabled_4.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_disabled_5.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_disabled_6.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_disabled_7.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_disabled_8.wav"),
]

const audio_voice_idlechat = [
    preload("res://sounds/valve_sounds/turret_floor/turret_idlechat_1.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_idlechat_2.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_idlechat_3.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_idlechat_4.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_idlechat_5.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_idlechat_6.wav"),
]

const audio_voice_pickup = [
    preload("res://sounds/valve_sounds/turret_floor/turret_pickup_1.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_pickup_2.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_pickup_3.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_pickup_4.wav"),
]

const audio_voice_retire = [
    preload("res://sounds/valve_sounds/turret_floor/turret_retire_1.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_retire_2.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_retire_4.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_retire_5.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_retire_6.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_retire_7.wav"),
]

const audio_voice_search = [
    preload("res://sounds/valve_sounds/turret_floor/turret_search_1.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_search_2.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_search_3.wav"),
    preload("res://sounds/valve_sounds/turret_floor/turret_search_4.wav"),
]
