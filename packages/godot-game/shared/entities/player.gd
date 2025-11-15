extends EntityBase
class_name Player
## Player entity data
##
## Represents a player (human or AI bot) in the world.
## Contains player-specific data like username, inventory, etc.

## Player-specific data
var username: String = ""
var auth_provider: String = "simple"  # simple, google, discord, etc.

## Gameplay data
var inventory: Dictionary = {}  # Item ID -> quantity
var health: float = 100.0
var max_health: float = 100.0

## Session data
var is_bot: bool = false  # True for AI agents
var last_login: int = 0
var session_start: int = 0

## Movement
const MOVE_SPEED: float = 200.0  # Pixels per second

## Constructor
func _init(p_id: int = -1, p_username: String = ""):
	super(p_id, EntityType.PLAYER)
	username = p_username
	session_start = Time.get_unix_time_from_system()
	last_login = session_start

## Update player (called each frame on server)
func update(delta: float) -> void:
	# Apply velocity to position
	position += velocity * delta

	# TODO: Add collision detection
	# TODO: Add boundary checks

	mark_updated()

## Set movement direction (normalized)
func set_movement_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		velocity = direction.normalized() * MOVE_SPEED
	else:
		velocity = Vector2.ZERO

## Serialize to dictionary (override to include player-specific data)
func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict["username"] = username
	dict["auth_provider"] = auth_provider
	dict["inventory"] = inventory
	dict["health"] = health
	dict["max_health"] = max_health
	dict["is_bot"] = is_bot
	dict["last_login"] = last_login
	return dict

## Deserialize from dictionary
static func from_dict(data: Dictionary) -> Player:
	var player = Player.new()

	# Base entity data
	player.id = data.get("id", -1)
	player.entity_type = data.get("type", EntityType.PLAYER)

	var pos = data.get("pos", [0, 0])
	player.position = Vector2(pos[0], pos[1])

	var vel = data.get("vel", [0, 0])
	player.velocity = Vector2(vel[0], vel[1])

	player.is_active = data.get("active", true)
	player.created_at = data.get("created_at", Time.get_unix_time_from_system())
	player.last_update = data.get("last_update", player.created_at)

	# Player-specific data
	player.username = data.get("username", "")
	player.auth_provider = data.get("auth_provider", "simple")
	player.inventory = data.get("inventory", {})
	player.health = data.get("health", 100.0)
	player.max_health = data.get("max_health", 100.0)
	player.is_bot = data.get("is_bot", false)
	player.last_login = data.get("last_login", Time.get_unix_time_from_system())

	return player

## Inventory management
func add_item(item_id: int, quantity: int = 1) -> void:
	var current = inventory.get(item_id, 0)
	inventory[item_id] = current + quantity

func remove_item(item_id: int, quantity: int = 1) -> bool:
	var current = inventory.get(item_id, 0)
	if current >= quantity:
		inventory[item_id] = current - quantity
		if inventory[item_id] == 0:
			inventory.erase(item_id)
		return true
	return false

func has_item(item_id: int, quantity: int = 1) -> bool:
	return inventory.get(item_id, 0) >= quantity

## Health management
func take_damage(amount: float) -> void:
	health = max(0.0, health - amount)
	mark_updated()

func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	mark_updated()

func is_alive() -> bool:
	return health > 0.0
