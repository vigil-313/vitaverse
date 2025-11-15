extends RefCounted
class_name EntityBase
## Base class for all entities in the world
##
## Entities are objects that exist in the world and have position, state, etc.
## This includes players, NPCs, AI agents, and eventually items/objects.

## Entity types
enum EntityType {
	PLAYER = 0,
	NPC = 1,
	AI_AGENT = 2,
	ITEM = 3,
	OBJECT = 4
}

## Entity state
var id: int = -1  # Unique entity ID (assigned by server)
var entity_type: EntityType = EntityType.PLAYER
var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var is_active: bool = true

## Metadata
var created_at: int = 0
var last_update: int = 0

## Constructor
func _init(p_id: int = -1, p_type: EntityType = EntityType.PLAYER):
	id = p_id
	entity_type = p_type
	created_at = Time.get_unix_time_from_system()
	last_update = created_at

## Update entity state (called each frame on server)
func update(delta: float) -> void:
	# Override in subclasses
	pass

## Serialize to dictionary
func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": entity_type,
		"pos": [position.x, position.y],
		"vel": [velocity.x, velocity.y],
		"active": is_active,
		"created_at": created_at,
		"last_update": last_update
	}

## Deserialize from dictionary
static func from_dict(data: Dictionary) -> EntityBase:
	var entity = EntityBase.new()
	entity.id = data.get("id", -1)
	entity.entity_type = data.get("type", EntityType.PLAYER)

	var pos = data.get("pos", [0, 0])
	entity.position = Vector2(pos[0], pos[1])

	var vel = data.get("vel", [0, 0])
	entity.velocity = Vector2(vel[0], vel[1])

	entity.is_active = data.get("active", true)
	entity.created_at = data.get("created_at", Time.get_unix_time_from_system())
	entity.last_update = data.get("last_update", entity.created_at)

	return entity

## Get current chunk position
func get_chunk_position() -> Vector2i:
	return WorldConstants.world_to_chunk(position)

## Mark entity as updated
func mark_updated() -> void:
	last_update = Time.get_unix_time_from_system()
