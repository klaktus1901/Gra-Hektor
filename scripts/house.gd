extends Node3D

var in_home = false
var in_basement = false
var lightning_sounds = [preload("res://sfx/lightning1.mp3"), preload("res://sfx/lightning2.mp3")]

func _ready() -> void:
	$GPUParticles3D.emitting = true
	while !in_basement:
		await get_tree().create_timer(randi_range(15, 60)).timeout
		spawn_lightning()

func spawn_lightning():
	var lightning_sound = AudioStreamPlayer3D.new()
	var lightning_light = OmniLight3D.new()
	lightning_light.omni_range = 200
	lightning_light.light_energy = 4.0
	lightning_sound.stream = lightning_sounds.pick_random()
	lightning_sound.max_distance = 200
	get_tree().current_scene.add_child(lightning_sound)
	get_tree().current_scene.add_child(lightning_light)
	lightning_light.position = Vector3(randi_range(-100, 100), randi_range(30, 70), randi_range(-100, 100))
	print(lightning_light.position)
	lightning_sound.position = lightning_light.position
	if in_home:
		lightning_sound.set_bus("in_home")
		lightning_sound.volume_db = 0
	lightning_sound.volume_db = 80
	lightning_sound.play()
	while lightning_light.light_energy > 0:
		lightning_light.light_energy -= 0.02
		await get_tree().create_timer(0.015).timeout
	await get_tree().create_timer(13.0).timeout
	lightning_light.queue_free()
	lightning_sound.queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	change_bus("in_home")
	in_home = true
	while $AudioStreamPlayer3D.volume_db > -20:
		if !in_home:
			return
		$AudioStreamPlayer3D.volume_db -= 1.0
		await get_tree().create_timer(0.1).timeout

func _on_area_3d_body_exited(body: Node3D) -> void:
	change_bus("master")
	in_home = false
	while $AudioStreamPlayer3D.volume_db < 0:
		if in_home:
			return
		$AudioStreamPlayer3D.volume_db += 1.0
		await get_tree().create_timer(0.1).timeout

func change_bus(bus):
	await get_tree().create_timer(1.0).timeout
	$AudioStreamPlayer3D.set_bus(bus)
