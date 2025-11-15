extends Node
## Global configuration management
##
## This autoload singleton provides configuration values that differ
## between development and production environments.

## Environment types
enum Environment {
	DEVELOPMENT,
	STAGING,
	PRODUCTION
}

## Current environment - change this when deploying
var current_environment: Environment = Environment.DEVELOPMENT

## Configuration values per environment
var configs := {
	Environment.DEVELOPMENT: {
		# Server settings
		"server_host": "127.0.0.1",
		"server_port": 9000,
		"max_players": 10,
		"tick_rate": 60,

		# Database
		"db_path": "user://vitaverse_dev.db",

		# World settings
		"chunk_save_interval": 60.0,  # Save every 60 seconds
		"auto_save": true,

		# Debug
		"debug_mode": true,
		"show_chunk_borders": false,
		"show_fps": true,
		"verbose_logging": true,
	},

	Environment.STAGING: {
		"server_host": "0.0.0.0",
		"server_port": 9000,
		"max_players": 50,
		"tick_rate": 60,
		"db_path": "user://vitaverse_staging.db",
		"chunk_save_interval": 30.0,
		"auto_save": true,
		"debug_mode": true,
		"show_chunk_borders": false,
		"show_fps": false,
		"verbose_logging": true,
	},

	Environment.PRODUCTION: {
		"server_host": "0.0.0.0",
		"server_port": 9000,
		"max_players": 100,
		"tick_rate": 60,
		"db_path": "user://vitaverse.db",
		"chunk_save_interval": 30.0,
		"auto_save": true,
		"debug_mode": false,
		"show_chunk_borders": false,
		"show_fps": false,
		"verbose_logging": false,
	}
}

## Get a configuration value for the current environment
func get_value(key: String, default = null):
	var env_config = configs.get(current_environment, {})
	return env_config.get(key, default)

## Convenience getters for common config values
func get_server_host() -> String:
	return get_value("server_host", "127.0.0.1")

func get_server_port() -> int:
	return get_value("server_port", 9000)

func get_max_players() -> int:
	return get_value("max_players", 10)

func get_tick_rate() -> int:
	return get_value("tick_rate", 60)

func is_debug_mode() -> bool:
	return get_value("debug_mode", false)

func get_db_path() -> String:
	return get_value("db_path", "user://vitaverse.db")

## Set environment (useful for testing)
func set_environment(env: Environment) -> void:
	current_environment = env
	print("[Config] Environment set to: ", Environment.keys()[env])

## Load environment from environment variable or command line
func _ready() -> void:
	# Check for environment variable
	var env_var = OS.get_environment("VITAVERSE_ENV")
	if env_var:
		match env_var.to_upper():
			"DEVELOPMENT", "DEV":
				current_environment = Environment.DEVELOPMENT
			"STAGING":
				current_environment = Environment.STAGING
			"PRODUCTION", "PROD":
				current_environment = Environment.PRODUCTION

	# Check command line arguments
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.begins_with("--env="):
			var env_str = arg.split("=")[1].to_upper()
			match env_str:
				"DEVELOPMENT", "DEV":
					current_environment = Environment.DEVELOPMENT
				"STAGING":
					current_environment = Environment.STAGING
				"PRODUCTION", "PROD":
					current_environment = Environment.PRODUCTION

	print("[Config] Running in ", Environment.keys()[current_environment], " mode")
