extends Node3D

@onready var entrance: Area3D = $entrance
@onready var closet: Area3D = $closet
@onready var corridor: Area3D = $corridor
@onready var bathroom: Area3D = $bathroom
@onready var kitchen: Area3D = $kitchen
@onready var bedroom: Area3D = $bedroom
@onready var bedroom_2: Area3D = $bedroom2
@onready var room: Area3D = $room
@onready var room_2: Area3D = $room2


@onready var connetions = {
	"entrance": [closet, corridor],
	"closet": [entrance],
	"corridor": [room, bathroom, bedroom_2, kitchen],
	"bathroom": [corridor],
	"kitchen": [corridor, bedroom],
	"bedroom": [bedroom_2, kitchen],
	"bedroom2": [corridor, bedroom],
	"room": [corridor, room_2],
	"room2": [room]
}

var current_room = ""

func _ready() -> void:
	print(entrance)

func _process(delta: float) -> void:
	pass

func detect_body_entered(body: Node3D, area: NodePath) -> void:
	print("weszłem: ", body, area)
	current_room = str(area)
	print("current_room: ", current_room )
	var random_connect_room = connetions[current_room].pick_random()
	# Zrobić mechanikę przejścia
	$"../../CharacterBody3D".position = random_connect_room.position

func detect_body_exited(body: Node3D, area: NodePath) -> void:
	print("wyszedłem: ", body, area)
