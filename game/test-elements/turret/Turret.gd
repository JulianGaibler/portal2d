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

export(bool) var looks_right = true

enum { IDLE, ALERT, SHOOTING, SEARCHING, HELD, DYING, DEAD }
enum x { IDLE, ALERT, SHOOTING, SEARCHING, HELD, DYING, DEAD }

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

func _ready():
    tracking_area.connect("body_entered", self, "enter_area")
    tracking_area.connect("body_exited", self, "leave_area")

func enter_area(body):
    if body.is_in_group("player"):
        tracked_player = body
        track_player = true
func leave_area(body):
    if body.is_in_group("player"): track_player = false

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
    update()

func fizzle():
    go_dead()
    .fizzle()

func _draw():
    var label = Label.new()
    var font = label.get_font("")
    draw_string ( font, Vector2(0, -100), "Turret is: %s"%x.keys()[state], Color.white)

### Behavior

func do_idle(delta, player):
    if can_see_player(player): go_alert()

func do_alert(delta, player):
    if !can_see_player(player): go_searching()
    look_at_player(player)
    if can_shoot_player(player): go_shooting()

func do_shooting(delta, player):
    if !can_see_player(player): go_searching()
    if !can_shoot_player(player): go_alert()
    look_at_player(player)
    var force = max(50, 400 - player.global_position.distance_to(global_position)/2)
    player.linear_velocity += (player.global_position - global_position).normalized() * force * rand_range(.4, 1.0)
    player.take_damage(2 * delta * force)

func do_searching(delta, player):
    timeout -= delta
    if can_see_player(player):
        go_alert()
    elif counter == 4:
        confused_look(0.4, 1.0)
        timeout = 1.0
        counter = 3
    elif timeout <= 0.0 and counter == 3:
        confused_look(-0.4, 1.0)
        timeout = 1.0
        counter = 2
    elif timeout <= 0.0 and counter == 2:
        confused_look(0.4, 1.0)
        timeout = 1.0
        counter = 1
    elif timeout <= 0.0 and counter == 1:
        go_idle()

func do_held(delta, player):
    timeout -= delta
    if being_held:
        if timeout <= 0.0 and counter == 1:
            confused_look(rand_range(.1,.6), .5)
            timeout = .5
            counter = 0
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

    animation_player.play("close")

func go_alert():
    bullet_particles.emitting = false
    if state == IDLE:
        animation_player.play("open")
    state = ALERT

func go_shooting():
    bullet_particles.emitting = true
    state = SHOOTING

func go_searching():
    bullet_particles.emitting = false
    state = SEARCHING
    counter = 4

func go_held():
    if state == IDLE:
        animation_player.play("open")
    bullet_particles.emitting = false
    state = HELD
    counter = 1
    timeout = 1.0

func go_dying():
    if state == IDLE:
        animation_player.play("open")
    bullet_particles.emitting = true
    timeout = 3.0
    counter = 1
    confused_look(.6, 0.4)
    state = DYING

func go_dead():
    state = DEAD
    animation_player.play("close")
    bullet_particles.emitting = false
    confused_look(0,1)
    laser_node.deactivate()
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
    var result = space_state.intersect_ray(laser_node.global_position, player.global_position+PLAYER_UP, [self] + get_tree().get_nodes_in_group("transparent"), BinaryLayers.FLOOR)
    
    if !result.empty() and result.collider == player: return true
    return false

func can_shoot_player(player) -> bool:
    if !track_player: return false
    
    var space_state = get_world_2d().direct_space_state
    var result = space_state.intersect_ray(laser_node.global_position, player.global_position+PLAYER_UP, [self], BinaryLayers.FLOOR)
    
    if !result.empty() and result.collider == player: return true
    return false
