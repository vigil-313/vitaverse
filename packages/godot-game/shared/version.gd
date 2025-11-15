extends Node
## Version management and protocol compatibility
##
## This autoload singleton manages version information and protocol compatibility.
## The protocol version must match between client and server for connection to succeed.

## Current protocol version - increment when making breaking changes to network protocol
const PROTOCOL_VERSION := "1.0.0"

## Game version (semantic versioning)
const GAME_VERSION := "0.1.0"

## Build information
const BUILD_DATE := "2025-11-15"
const BUILD_TYPE := "development"  # development, alpha, beta, release

## Minimum supported client version (for backward compatibility)
const MIN_CLIENT_VERSION := "0.1.0"

## Checks if a client version is compatible with this server
func is_client_compatible(client_version: String) -> bool:
	# For now, exact match required
	# Later can implement semantic version comparison
	return client_version == GAME_VERSION

## Checks if protocol versions match
func is_protocol_compatible(client_protocol: String) -> bool:
	return client_protocol == PROTOCOL_VERSION

## Returns version information as a dictionary
func get_version_info() -> Dictionary:
	return {
		"game_version": GAME_VERSION,
		"protocol_version": PROTOCOL_VERSION,
		"build_date": BUILD_DATE,
		"build_type": BUILD_TYPE
	}

## Prints version information to console (useful for debugging)
func print_version_info() -> void:
	print("=== Vitaverse ===")
	print("Game Version: ", GAME_VERSION)
	print("Protocol Version: ", PROTOCOL_VERSION)
	print("Build Date: ", BUILD_DATE)
	print("Build Type: ", BUILD_TYPE)
	print("=================")

func _ready() -> void:
	if OS.is_debug_build():
		print_version_info()
