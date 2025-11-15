extends Node
class_name WorldManager
## Manages world simulation and state
##
## Handles environmental updates, plant growth, decay, weather, etc.

## World settings
var simulation_speed: float = 1.0  # Multiplier for simulation speed
var time_of_day: float = 12.0  # 0-24 hours
var day_length: float = 1200.0  # Real seconds for one in-game day

## Simulation state
var total_ticks: int = 0
var last_save_time: float = 0.0
var save_interval: float = 60.0  # Save every 60 seconds

## Update world simulation
func update(delta: float) -> void:
	total_ticks += 1

	# Update time of day
	_update_time_of_day(delta)

	# Periodic simulation updates
	if total_ticks % 60 == 0:  # Once per second
		_update_simulation_slow()

	# Auto-save
	if Time.get_ticks_msec() / 1000.0 - last_save_time > save_interval:
		_auto_save()

## Update time of day
func _update_time_of_day(delta: float) -> void:
	var hours_per_second = 24.0 / day_length
	time_of_day += hours_per_second * delta * simulation_speed

	if time_of_day >= 24.0:
		time_of_day -= 24.0
		_on_new_day()

## Called when a new day starts
func _on_new_day() -> void:
	if Config.is_debug_mode():
		print("[WorldManager] New day started")

	# TODO: Daily events
	# - Plant growth
	# - NPC behavior changes
	# - Economy updates

## Slow simulation updates (once per second)
func _update_simulation_slow() -> void:
	# TODO: Implement simulation tiers
	# - Active chunks: Full simulation
	# - Near chunks: Simplified simulation
	# - Far chunks: Statistical simulation
	# - Dormant chunks: Time-compressed formulas
	pass

## Auto-save world state
func _auto_save() -> void:
	if not Config.get_value("auto_save", true):
		return

	last_save_time = Time.get_ticks_msec() / 1000.0

	# This is handled by chunk_manager
	# WorldManager just triggers it
	if Config.is_debug_mode():
		print("[WorldManager] Auto-save triggered")

## Get current time of day as string
func get_time_string() -> String:
	var hours = int(time_of_day)
	var minutes = int((time_of_day - hours) * 60)
	return "%02d:%02d" % [hours, minutes]

## Check if it's daytime
func is_daytime() -> bool:
	return time_of_day >= 6.0 and time_of_day < 18.0

## Get light level (0.0 - 1.0)
func get_light_level() -> float:
	if time_of_day >= 6.0 and time_of_day < 12.0:
		# Morning: gradually brighten
		return (time_of_day - 6.0) / 6.0
	elif time_of_day >= 12.0 and time_of_day < 18.0:
		# Day: full brightness
		return 1.0
	elif time_of_day >= 18.0 and time_of_day < 22.0:
		# Evening: gradually darken
		return 1.0 - ((time_of_day - 18.0) / 4.0)
	else:
		# Night: dark
		return 0.2

## Plant growth simulation (future)
func simulate_plant_growth(chunk: Chunk, time_elapsed: float) -> void:
	# TODO: Implement plant growth
	# For each plant tile in chunk:
	# - Check water level, sunlight, etc.
	# - Update growth stage
	# - Possibly spawn new plants nearby
	pass

## Building decay simulation (future)
func simulate_decay(chunk: Chunk, time_elapsed: float) -> void:
	# TODO: Implement decay
	# For each building tile in chunk:
	# - Check if maintained
	# - Gradually degrade quality
	# - Eventually collapse/change tile type
	pass

## Weather system (future)
var current_weather: String = "clear"  # clear, rain, snow, fog

func update_weather(delta: float) -> void:
	# TODO: Implement weather system
	# - Random weather changes
	# - Weather affects plant growth
	# - Weather affects visibility
	pass
