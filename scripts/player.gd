extends CharacterBody3D

@onready var camera = $camera_controler/Camera3D
@onready var camera_controler = $camera_controler
@onready var cam = $camera_controler/Camera3D/Sketchfab_Scene
@onready var animations = $AnimationPlayer

var speed = 1.0

var can_flash = true
var cam_equiped = false
var can_equip = true
var sprint_speed = 3.5
var walk_speed = 2.0
var crouch_speed = 1.0
var jump_velocity = 3.0
var camera_sensitivity = 0.0015
var camera_start_position: Vector3

const bob_freq = 4.0
const bob_amp = 0.03
var t_bob = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func take_photo():
	can_flash = false
	$camera_controler/Camera3D/Sketchfab_Scene/SpotLight3D.show()
	$camera_controler/Camera3D/Sketchfab_Scene/SubViewport.render_target_update_mode = 1
	await get_tree().create_timer(0.1).timeout
	$camera_controler/Camera3D/Sketchfab_Scene/SpotLight3D.hide()
	await get_tree().create_timer(1.0).timeout
	can_flash = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jeden"):
		if !cam_equiped and can_equip:
			can_equip = false
			cam.show()
			animations.play("cam_eq")
			await get_tree().create_timer(1.5).timeout
			cam_equiped = true
			can_equip = true
		elif cam_equiped and can_equip:
			can_equip = false
			animations.play_backwards("cam_eq")
			await get_tree().create_timer(1.5).timeout
			cam_equiped = false
			can_equip = true
			cam.hide()
	if event.is_action_pressed("lpm") and cam_equiped and can_flash:
		take_photo()

func _ready() -> void:
	camera_start_position = camera.position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_controler.rotate_y(-event.relative.x * camera_sensitivity)
		camera.rotate_x(-event.relative.y * camera_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("skok") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	elif Input.is_action_pressed("kucanie"):
		$CollisionShape3D.shape.height = 1.0
		speed = crouch_speed
	else:
		$CollisionShape3D.shape.height = 2.0
		speed = walk_speed
	if Input.is_action_pressed("ppm") and cam_equiped:
		$camera_controler/Camera3D/Sprite2D.show()
	else:
		$camera_controler/Camera3D/Sprite2D.hide()
	$camera_controler/Camera3D/Sketchfab_Scene/SubViewport/Camera3D.transform = $camera_controler/Camera3D/Sketchfab_Scene/cam_position.global_transform
	var input_dir = Input.get_vector("lewo", "prawo", "przod", "tyl")
	var direction = (camera_controler.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.position = camera_start_position + _headbob(t_bob)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
