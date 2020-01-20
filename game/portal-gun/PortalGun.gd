extends Node2D

const COLOR_BLUE = Color("#6fa5ad")
const COLOR_ORANGE = Color("#dcba54")

const Portal = preload("res://portal/Portal.tscn")
const PortalOrientation = preload("res://portal/Portal.gd").PortalOrientation
const PortalType = preload("res://portal/Portal.gd").PortalType
const PORTAL_HEIGHT = preload("res://portal/Portal.gd").PORTAL_HEIGHT
const BinaryLayers = preload("res://Layers.gd").BinaryLayers
const probing_space = 10

const audio_shoot = [
    "res://sounds/portal-gun/gun1.wav",
    "res://sounds/portal-gun/gun2.wav",
    "res://sounds/portal-gun/gun3.wav",
    "res://sounds/portal-gun/gun4.wav",
    "res://sounds/portal-gun/gun5.wav"
    ]
const audio_invalid = [
    "res://sounds/valve_sounds/Portal_invalid_surface_01.wav",
    "res://sounds/valve_sounds/Portal_invalid_surface_02.wav",
    "res://sounds/valve_sounds/Portal_invalid_surface_03.wav",
    "res://sounds/valve_sounds/Portal_invalid_surface_04.wav"
    ]
export(bool) var allow_primary = true
export(bool) var allow_secondary = true
var show_hint = false

onready var active_end := $ActiveEnd
onready var animation_player := $AnimationPlayer
onready var light := $Polygons/Polygon2D8/Light2D
onready var player_shoot := $Sound
onready var player_invalid := $InvalidSurface

var exclude = []

func _ready():
    set_process(false)

func refresh_exclude_array():
    exclude = get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("dynamic-prop") + get_tree().get_nodes_in_group("portal-ignore")

func toggle_hint():
    show_hint = !show_hint
    if show_hint:
        refresh_exclude_array()
        set_process(true)

func play_sound_shoot():
    randomize()
    player_shoot.set_stream(load(audio_shoot[randi()%audio_shoot.size()]))
    player_shoot.play()

func play_sound_invalid():
    randomize()
    player_invalid.set_stream(load(audio_invalid[randi()%audio_invalid.size()]))
    player_invalid.play()

func _process(delta):
    update()

func _draw():
    if show_hint:
        var ray = cast_ray()[0]
        if ray.empty(): return
        draw_line(active_end.position, to_local(ray.position), Color(1,1,1,0.05), 2.0, true)
    else:
        set_process(false)

func primary_fire():
    if allow_primary:
        light.color = COLOR_BLUE
        shoot_portal(PortalType.BLUE_PORTAL)

func secondary_fire():
    if allow_secondary:
        light.color = COLOR_ORANGE    
        shoot_portal(PortalType.ORANGE_PORTAL)

func cast_ray():
    var direction = (active_end.global_position - global_position).normalized()
    var space_state = get_world_2d().direct_space_state
    var hit = space_state.intersect_ray(global_position, global_position + (direction * 3000), exclude, BinaryLayers.FLOOR | BinaryLayers.WHITE)
    return [hit, direction]

func shoot_portal(type):
    refresh_exclude_array()
    animation_player.play("shoot")
    play_sound_shoot()
    var data = cast_ray()
    if data[0].empty(): return
    var corrected_position = check_and_correct_placement(data[0], type, exclude)
    if (corrected_position != null):
        var deg = rad2deg(Vector2.RIGHT.angle_to(data[1]))
        # if we can place the portal adjust the position
        spawn_portal(corrected_position, data[0].normal, deg, type)
    else:
        play_sound_invalid()


func spawn_portal(hit_position: Vector2, normal: Vector2, deg: float, type):
	var instance = Portal.instance()
	Game.get_scene_root().add_child(instance)
	var orientation = PortalOrientation.UP
	# getting the correct orientation
	if normal == Vector2.UP or normal == Vector2.DOWN:
		if (deg < 90 and deg > 0) or (deg > -180 and deg < -90):
			orientation = PortalOrientation.DOWN
	else:
		if deg < 90 and deg > -90:
			orientation = PortalOrientation.DOWN
	instance.position = hit_position
	# rotating the portal to fit the white layer
	instance.rotation_degrees = rad2deg(atan2(normal.y, normal.x))
	instance.initiate(type, orientation)

func check_and_correct_placement(hit: Dictionary, type, exclude: Array):
	# Check if hit-collider has portal-surface
	if !hit.collider.is_in_group("white_layer"): return null
	var space_state = get_world_2d().direct_space_state

	# Normal that's pointing up relativ to the surface
	var normal_up = Vector2(hit.normal.y, -hit.normal.x)  # clockwise -90

	# Check if the surface is continous and unobstructed
	var below_surface_continuity = check_surface_continuity(space_state, hit, normal_up, -0.5, [hit.collider] + exclude, type)
	var above_surface_continuity = check_surface_continuity(space_state, hit, normal_up, 0.5, exclude, type)

	# These are the distances from the portal center up and down to the next collision (interruption of the surface)
	var dist_top = min(below_surface_continuity[0], above_surface_continuity[0])
	var dist_btm = min(below_surface_continuity[1], above_surface_continuity[1])

	var moved_position = hit.position

	# Chck if a collision occured before the portal is supposed to end
	# If that's the case, test if the portal can be moved in the other direction
	if dist_top < 999 or dist_btm < 999:
		if dist_top < PORTAL_HEIGHT:
			var overshoot = (PORTAL_HEIGHT - dist_top) + 5
			if dist_btm - overshoot - PORTAL_HEIGHT >= 0:
				moved_position = hit.position + -normal_up * overshoot
				dist_btm -= overshoot
				dist_top += overshoot
			else:
				return null
		elif dist_btm < PORTAL_HEIGHT:
			var overshoot = (PORTAL_HEIGHT - dist_btm) + 5
			if dist_top - overshoot - PORTAL_HEIGHT >= 0:
				moved_position = hit.position + normal_up * overshoot
				dist_top -= overshoot
				dist_btm += overshoot
			else:
				return null

	# Checks if the start end end of the portal are the in the air.
	# If that's the case the method tries to move to portal according to dist_top and dist_btm
	var moved_portal1 = probe_for_air(space_state, moved_position, hit.normal, normal_up, dist_top, -1, exclude)
	if moved_portal1 == null:
		var moved_portal2 = probe_for_air(space_state, moved_position, hit.normal, normal_up, dist_btm, 1, exclude)
		if moved_portal2 == null: return null
		else: moved_position = moved_portal2
	else:
		moved_position = moved_portal1

	return moved_position


func probe_for_air(space_state, position, normal, normal_up, dist, direction, exclude):
	var start = position + (normal * 0.5)
	var moved_by = 0

	while true:
		var end_top = start + (normal_up * moved_by) + (normal_up * (PORTAL_HEIGHT))
		var top = space_state.intersect_ray(end_top, end_top + (normal * -1), exclude, BinaryLayers.FLOOR)
		var end_btm = start + (normal_up * moved_by) + (-normal_up * (PORTAL_HEIGHT))
		var btm = space_state.intersect_ray(end_btm, end_btm + (normal * -1), exclude, BinaryLayers.FLOOR)
		if top.empty() or !top.collider.is_in_group("white_layer") or btm.empty() or !btm.collider.is_in_group("white_layer"):
			dist -= probing_space
			if dist - PORTAL_HEIGHT < 0: return null
			moved_by += probing_space * direction
			continue
		break

	return position + (normal_up * moved_by)

func check_surface_continuity(space_state, hit, normal_up, distance, exclude, type):
	var cont_area_start = hit.position + (hit.normal * distance)
	var clear_ray_end_top = cont_area_start + (normal_up * PORTAL_HEIGHT * 2)
	var clear_ray_end_btm = cont_area_start + ((-normal_up) * PORTAL_HEIGHT * 2)

	var other_portal = BinaryLayers.ORANGE_PORTAL if type == PortalType.BLUE_PORTAL else BinaryLayers.BLUE_PORTAL

	var cont_area_top = space_state.intersect_ray(cont_area_start, clear_ray_end_top, exclude, BinaryLayers.FLOOR | other_portal)
	var cont_area_btm = space_state.intersect_ray(cont_area_start, clear_ray_end_btm, exclude, BinaryLayers.FLOOR | other_portal)

    return [dist_top, dist_btm]

## Public methods:

func change_visibility(to: bool):
    visible = to

func change_shooting(nr: int, to: bool):
    match nr:
        1: allow_primary = to
        2: allow_secondary = to
