extends Camera2D
## Camera controller
##
## Follows the player smoothly and handles zoom.

## Target to follow (usually the player)
@export var target: Node2D

## Smooth follow
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

## Zoom controls
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var zoom_speed: float = 0.1

func _ready() -> void:
	# Make this the active camera
	make_current()

func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_apply_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_apply_zoom(-zoom_speed)

func _apply_zoom(delta: float) -> void:
	var new_zoom = zoom.x + delta
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)

func _process(delta: float) -> void:
	# Follow target
	if target:
		if smoothing_enabled:
			global_position = global_position.lerp(target.global_position, smoothing_speed * delta)
		else:
			global_position = target.global_position

	# Handle zoom input
	_handle_zoom()

func _handle_zoom() -> void:
	var zoom_delta = 0.0

	# Mouse wheel zoom is handled in _unhandled_input
	# Keyboard zoom (optional: + and -)
	if Input.is_action_pressed("ui_page_up"):
		zoom_delta = zoom_speed * 0.1
	elif Input.is_action_pressed("ui_page_down"):
		zoom_delta = -zoom_speed * 0.1

	if zoom_delta != 0.0:
		var new_zoom = zoom.x + zoom_delta
		new_zoom = clamp(new_zoom, min_zoom, max_zoom)
		zoom = Vector2(new_zoom, new_zoom)

func set_target(new_target: Node2D) -> void:
	target = new_target
