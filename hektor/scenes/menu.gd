extends Node3D


func _ready() -> void:
	$GPUParticles3D.emitting = true
	$AnimationPlayer.play("intro")


func _on_button_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print("cos")
	print(camera, event, event_position)
	if event.is_action_pressed("lpm"):
		print("eloelo")
