# Godot Editor Setup Guide

This guide walks you through setting up the visual assets in Godot Editor.
**Estimated time: 10-15 minutes**

## Prerequisites

✅ Assets are in place:
- `client/assets/tilesets/placeholder/terrain_atlas.png`
- `client/assets/sprites/placeholder/player.png`

## Step 1: Open Project in Godot

1. Open Godot 4
2. Click "Import"
3. Navigate to: `/Users/vigil-313/vitaverse/packages/godot-game`
4. Select `project.godot`
5. Click "Import & Edit"

Godot will open and import all assets automatically.

---

## Step 2: Create TileSet Resource

### 2.1 Open the TileMap

1. In the **FileSystem** panel (bottom-left), navigate to:
   ```
   res://client/scenes/game_world.tscn
   ```
2. Double-click to open the scene
3. In the **Scene** tree (top-left), select: `WorldRenderer > TileMap`

### 2.2 Create New TileSet

1. In the **Inspector** panel (right side), find the **TileSet** property
2. It currently says `<empty>`
3. Click the dropdown arrow next to `<empty>`
4. Select **"New TileSet"**
5. Click on the TileSet to edit it

### 2.3 Add Terrain Atlas to TileSet

1. At the bottom of the editor, you'll see the **TileSet** panel appear
2. Click the **"+"** button in the bottom panel
3. Select **"Atlas"**
4. A file picker will appear
5. Navigate to: `res://client/assets/tilesets/placeholder/terrain_atlas.png`
6. Click **"Open"**

### 2.4 Configure the Atlas

The terrain atlas should now appear in the TileSet editor.

1. In the bottom panel, make sure the atlas is selected
2. On the right side of the TileSet panel, find **"Texture Region Size"**
3. Set it to: `32 x 32` (this tells Godot each tile is 32x32 pixels)
4. Godot will automatically slice the atlas into individual tiles

### 2.5 Set Up Tile IDs (Basic)

For now, we'll use automatic tile IDs. Later you can map specific tiles to specific TileType enums.

1. In the TileSet panel, you should see a grid of tiles from the atlas
2. Click on any tile to select it
3. The tile ID is shown in the bottom-left (starts at 0, 1, 2, etc.)

**Note:** You'll need to manually map these IDs to your `TileDefinitions.TileType` enum later.
For now, just verify the tiles appear and can be selected.

### 2.6 Save the TileSet

1. In the **Inspector** panel (where you created the TileSet)
2. Click the dropdown arrow next to the TileSet again
3. Select **"Save"**
4. Save it as: `res://client/assets/tilesets/placeholder/terrain_atlas.tres`
5. Click **"Save"**

✅ **TileSet is now created and assigned to the TileMap!**

---

## Step 3: Add Player Sprite

### 3.1 Open Player Node

1. In the **Scene** tree, expand: `Player`
2. Select the `Sprite2D` node (under Player)

### 3.2 Assign Texture

1. In the **Inspector** panel, find the **Texture** property
2. Click the dropdown arrow
3. Select **"Load"**
4. Navigate to: `res://client/assets/sprites/placeholder/player.png`
5. Click **"Open"**

You should now see the player sprite sheet in the viewport!

### 3.3 Configure Sprite Sheet (Optional - for animations)

The player.png is an animation sprite sheet. To slice it:

1. With Sprite2D still selected, in the Inspector find **Animation**
2. Set **Hframes**: `9` (9 frames horizontally)
3. Set **Vframes**: `4` (4 directions vertically)
4. Set **Frame**: `0` (this selects which frame to display)

Now the sprite is sliced into 9x4 = 36 individual frames!

**For now**, just leave Frame at 0 to show the first frame.

### 3.4 Center the Sprite

1. With Sprite2D selected, find **Offset** in the Inspector
2. Set **Centered**: **ON** (checkmark)
3. This ensures the sprite rotates around its center

✅ **Player sprite is now configured!**

---

## Step 4: Fix Main Menu

### 4.1 Open Main Menu Scene

1. In **FileSystem**, navigate to: `res://client/scenes/main_menu.tscn`
2. Double-click to open

### 4.2 Attach Script

1. Select the root node in the Scene tree (should be named "MainMenu" or similar)
2. In the **Inspector**, find the **Script** property at the top
3. Click the dropdown
4. Select **"Load"**
5. Navigate to: `res://client/scripts/main_menu.gd`
6. Click **"Open"**

### 4.3 Wire Up UI Signals (if needed)

The script should automatically handle button connections via code.
If you see errors in the console about missing nodes, we'll debug later.

✅ **Main menu script is attached!**

---

## Step 5: Save Everything

1. Press **Ctrl+S** (Windows/Linux) or **Cmd+S** (Mac) to save
2. Or: **Scene > Save Scene**
3. Save any modified scenes

---

## Step 6: Test the Project

### 6.1 Quick Test (Client Only)

1. Press **F5** or click the **"Play"** button (top-right)
2. Godot will ask which scene to run
3. Select: `res://client/scenes/main_menu.tscn`
4. Click **"Select Current"**

The main menu should appear!

### 6.2 What to Expect

At this point:
- ✅ Main menu should display
- ✅ Can enter username
- ⚠️  Server won't be running yet (so connection will fail)
- ⚠️  No world data yet (Seattle not imported)

---

## Next Steps

After completing this guide:

1. **Run the world importer** to generate Seattle chunk data
2. **Start the server** in headless mode
3. **Connect the client** and explore Seattle!

See the main session for instructions on those steps.

---

## Troubleshooting

### "Cannot find texture"
- Make sure assets are in the correct folders
- Check that `.import` files exist next to each PNG
- Reimport: Right-click PNG → Reimport

### "Script error" on main_menu.gd
- Check console for specific error
- Verify script path is correct
- Nodes might have different names than expected

### Tiles appear blurry
- Select the texture in FileSystem
- In Inspector, **Filter**: set to **Nearest**
- Click **Reimport**

### Player sprite looks wrong
- Check Hframes and Vframes are set correctly (9x4)
- Try different Frame values to see different poses

---

## Quick Reference

### File Locations
```
Assets:
res://client/assets/tilesets/placeholder/terrain_atlas.png
res://client/assets/sprites/placeholder/player.png

Scenes:
res://client/scenes/game_world.tscn
res://client/scenes/main_menu.tscn

Scripts:
res://client/scripts/main_menu.gd
res://client/scripts/player_controller.gd
res://client/scripts/world_renderer.gd
```

### TileSet Path
Save TileSet as: `res://client/assets/tilesets/placeholder/terrain_atlas.tres`

---

**When you're done, return to the terminal and let me know!**
We'll then proceed with importing Seattle data and testing the full game.
