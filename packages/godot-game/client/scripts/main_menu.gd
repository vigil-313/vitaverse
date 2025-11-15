extends Control
## Main menu script
##
## Handles username input and connection to server

@onready var username_input: LineEdit = $VBoxContainer/UsernameInput
@onready var connect_button: Button = $VBoxContainer/ConnectButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	# Connect button signals
	connect_button.pressed.connect(_on_connect_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Set default username
	username_input.text = "Player" + str(randi() % 1000)
	username_input.select_all()
	username_input.grab_focus()

func _on_connect_pressed() -> void:
	var username = username_input.text.strip_edges()

	# Validate username
	if username.is_empty():
		print("[MainMenu] Username cannot be empty")
		return

	if not Protocol.validate_username(username):
		print("[MainMenu] Invalid username - must be 3-20 alphanumeric characters")
		return

	print("[MainMenu] Connecting as: ", username)

	# Store username in a global way (using Config autoload)
	# The game world will read this
	Config.set_value("username", username)

	# Change to game scene
	get_tree().change_scene_to_file("res://client/scenes/game_world.tscn")

func _on_quit_pressed() -> void:
	print("[MainMenu] Quitting...")
	get_tree().quit()
