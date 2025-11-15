extends CharacterBody2D
## Player controller for local player
##
## Handles movement input and sends state to server.

## Movement
@export var move_speed: float = 200.0

## Network client reference
@onready var network_client: Node = get_node("/root/GameWorld/NetworkClient")

## Visual representation
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

## Player username
var username: String = "Player"

## Last sent position (to avoid sending duplicate packets)
var last_sent_position: Vector2 = Vector2.ZERO
var last_sent_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Set player name label
	label.text = username

func _physics_process(delta: float) -> void:
	# Get input
	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	# Update velocity
	velocity = input_dir * move_speed

	# Move
	move_and_slide()

	# Send state to server if changed
	if network_client and network_client.is_connected():
		if position != last_sent_position or velocity != last_sent_velocity:
			network_client.send_player_move(position, velocity)
			last_sent_position = position
			last_sent_velocity = velocity

func set_username(p_username: String) -> void:
	username = p_username
	if label:
		label.text = username
