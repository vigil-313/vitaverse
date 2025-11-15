extends Node

## Asset Configuration
##
## This is the SINGLE SOURCE OF TRUTH for all asset paths in Vitaverse.
## To swap from placeholder to custom assets, just change the USE_CUSTOM_ASSETS flag.
##
## All other scripts should reference this config instead of hardcoding paths.

## Asset Mode Configuration
## Set to true to use custom assets, false to use placeholders
const USE_CUSTOM_ASSETS: bool = false

## Base Paths
const ASSETS_BASE = "res://client/assets/"
const TILESETS_BASE = ASSETS_BASE + "tilesets/"
const SPRITES_BASE = ASSETS_BASE + "sprites/"

## Asset Variant Paths
const PLACEHOLDER_SUFFIX = "placeholder/"
const CUSTOM_SUFFIX = "custom/"

## Current Asset Paths (automatically determined by USE_CUSTOM_ASSETS)
static func get_tileset_path() -> String:
	var variant = CUSTOM_SUFFIX if USE_CUSTOM_ASSETS else PLACEHOLDER_SUFFIX
	return TILESETS_BASE + variant

static func get_sprite_path() -> String:
	var variant = CUSTOM_SUFFIX if USE_CUSTOM_ASSETS else PLACEHOLDER_SUFFIX
	return SPRITES_BASE + variant

## Specific Asset Files
## These define the actual filenames - change these if you rename files

# Tileset files
const TILESET_TERRAIN_FILE = "terrain_atlas.tres"  # Godot TileSet resource
const TILESET_TERRAIN_PNG = "terrain_atlas.png"    # Source PNG

# Sprite files
const PLAYER_SPRITE_FILE = "player.png"
const PLAYER_ANIMATIONS = "player_animations.tres"  # Optional animation resource

## Full Asset Paths (use these in your code)
static func get_terrain_tileset() -> String:
	return get_tileset_path() + TILESET_TERRAIN_FILE

static func get_terrain_png() -> String:
	return get_tileset_path() + TILESET_TERRAIN_PNG

static func get_player_sprite() -> String:
	return get_sprite_path() + PLAYER_SPRITE_FILE

static func get_player_animations() -> String:
	return get_sprite_path() + PLAYER_ANIMATIONS

## Asset Information
static func get_asset_mode() -> String:
	return "custom" if USE_CUSTOM_ASSETS else "placeholder"

static func is_using_custom_assets() -> bool:
	return USE_CUSTOM_ASSETS

## Debug Info
static func print_asset_info() -> void:
	print("=== Vitaverse Asset Configuration ===")
	print("Mode: ", get_asset_mode())
	print("Tileset path: ", get_tileset_path())
	print("Sprite path: ", get_sprite_path())
	print("Terrain tileset: ", get_terrain_tileset())
	print("Player sprite: ", get_player_sprite())
	print("=====================================")
