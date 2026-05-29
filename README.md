[![English](https://img.shields.io/badge/English-blue.svg)](README.md)
[![中文](https://img.shields.io/badge/中文-red.svg)](README_zh.md)

---

# Velocity — NOMI Racing

A Forza-style 3D racing game with an AI co-pilot named NOMI, built entirely in Godot 4.6.3 with GDScript. All geometry is procedurally generated — zero imported 3D models.

## Why This Project?

Velocity isn't just another racing game — it's a complete racing simulation with personality. The NOMI AI assistant comments on your driving in real-time, celebrates your victories, and reacts to your collisions. Five distinct racing modes span from street circuits to desert rally stages, each with its own physics feel and championship season.

Every car, track, and mesh is built procedurally from CSG primitives and ArrayMesh, making the entire game self-contained with no external asset dependencies.

## Features

- **5 Racing Modes:** Street (GT), Formula 1, Baja Desert Rally, NASCAR, NIO
- **46 Cars** across 11 vehicle types — including 4 NIO models (ES7, ET5, ET7, EP9)
- **14 Tracks** — ovals, street circuits, mountain roads, point-to-point desert stages, superspeedways
- **NOMI AI Co-Pilot** — real-time commentary, expressions, drift tracking, victory celebrations
- **Full Season Championships** for each mode with authentic points systems (FIA, NASCAR, SCORE)
- **AI Opponents** with 3 difficulty levels, rubber-banding, and obstacle avoidance
- **Split-Screen Multiplayer** (2 players, independent HUDs)
- **Garage & Progression** — earn credits, unlock cars, 12 achievements
- **Advanced Physics** — 120Hz VehicleBody3D, weight transfer, drift model, slipstream, DRS
- **Procedural Audio** — engine, drift, collision, and UI sounds generated at runtime

## Quick Start

### Prerequisites

- [Godot 4.6.3+](https://godotengine.org/download) (Windows, macOS, or Linux)

### Run

```bash
# Clone
git clone git@github.com:twmissingu/nomi-racing-v2.git
cd nomi-racing-v2

# Launch
godot --path .
```

Or open the project folder in the Godot editor and press F5.

## Controls

| Key | Action |
|-----|--------|
| W / S | Accelerate / Brake |
| A / D | Steer |
| Space | Handbrake |
| Q | Look back |
| R | Reset car |
| ESC | Pause |

Gamepad supported: Right trigger (throttle), Left trigger (brake), Left stick (steering).

Split-screen Player 2: Arrow Keys + Numpad.

## For AI Agents

This project is designed for seamless AI agent interaction:

```bash
# Clone and enter
git clone git@github.com:twmissingu/nomi-racing-v2.git
cd nomi-racing-v2

# Headless validation (no display needed)
/opt/homebrew/bin/godot --headless --path . --quit

# Run the game
/opt/homebrew/bin/godot --path .
```

**Key architecture:**
- 4 autoloads: `InputManager`, `SaveManager`, `GameManager`, `RaceManager` (load order matters)
- All UI built in GDScript code (no .tscn UI scenes)
- Cars use composition: controllers as child nodes of VehicleBody3D
- Tracks generate geometry in `_ready()` via ArrayMesh + CSG
- Physics at 120Hz for VehicleBody3D stability

See [CLAUDE.md](CLAUDE.md) for full technical documentation.

## Project Structure

```
autoloads/          # InputManager, SaveManager, GameManager, RaceManager
cars/               # CarBase, controllers, 46 car definitions, 11 mesh builders
tracks/             # TrackData, 14 track scenes, checkpoint system
scenes/             # Race orchestrator, split-screen, camera, countdown, results
ui/                 # Main menu, garage, track select, race setup, HUD, pause, settings, season
nomi/               # NOMI controller, HUD avatar, commentary system
data/               # Player profile, race result structures
```

## License

[MIT](LICENSE)
