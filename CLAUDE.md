# Boorger

A two-player async restaurant game built in Godot 4.7 (2D).

## Game Overview

Two players cooperate asynchronously:

- **Player 1 (Catcher):** Moves a character to catch falling tetris-like blocks representing food. The catcher fills a 3x3 grid. At any point, they can send the contents of their grid to Player 2.
- **Player 2 (Plater):** Receives the food blocks and arranges them onto customer plates. Customer plates are grids of varying sizes and shapes (made up of unit squares, but the overall shape can be irregular -- briefcase-shaped, umbrella-shaped, etc).

## Current Focus

We are currently building the **Player 2 (Plater) prototype**. See `P2-PROTOTYPE.md` for details.

## Development Setup

- **Engine:** Godot 4.7.2 (Forward+ renderer)
- **No MCP server or Godot CLI usage.** All development is done by editing `.tscn`, `.gd`, `.tres`, and `project.godot` files directly.
- Scene files (`.tscn`) are edited as text. GDScript (`.gd`) is the scripting language.
- For tasks that are difficult to do via text editing alone (e.g. finding/importing art assets, creating complex node hierarchies, visual tweaking), ask the user to do it manually in the Godot editor.

## Project Structure

- `project.godot` -- project configuration
- `main.tscn` -- main scene
- `P2-PROTOTYPE.md` -- Player 2 prototype specification
