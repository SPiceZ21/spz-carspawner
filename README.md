<div align="center">

<img src="https://github.com/SPiceZ21/spz-core-media-kit/raw/main/Banner/Banner%232.png" alt="SPiceZ-Core Banner" width="100%"/>

<br/>

# spz-carspawner

### Branded Vehicle Depot & Deployment System

*Your personal machine depot. Browse, filter, and deploy any machine from the SPiceZ registry.*

<br/>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-orange.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)
[![FiveM](https://img.shields.io/badge/FiveM-Compatible-orange?style=flat-square)](https://fivem.net)
[![Lua](https://img.shields.io/badge/Lua-5.4-blue?style=flat-square&logo=lua)](https://lua.org)
[![Status](https://img.shields.io/badge/Status-In%20Development-green?style=flat-square)]()

</div>

---

## Overview

`spz-carspawner` is a standalone vehicle deployment tool. It provides a searchable NUI menu that pulls data directly from the central `spz-vehicles` registry. Whether you need a specific model via command or want to browse the depot visually, this script manages the spawning and cleanup of your freeroam machines.

---

## Features

- **Central Registry Sync** — Automatically pulls every registered vehicle from the `spz-vehicles` module.
- **Searchable Depot UI** — Filter through the vehicle list by label or model name in real-time.
- **Command-Based Spawning** — Use `/car [model]` for instant deployment or just `/car` to browse the depot.
- **Rapid Cleanup** — Use `/dv` to instantly despawn the current vehicle or the one you are looking at.
- **Branded Design** — Follows the official SPiceZ brand guidelines with Panchang typography and orange accents.

---

## Dependencies

| Resource | Version | Role |
|---|---|---|
| `spz-lib` | 1.0.0+ | Shared utilities |
| `spz-vehicles` | 1.0.0+ | Vehicle registry and core spawning API |

---

## Installation

1. Ensure the resource folder is named `spz-carspawner`.
2. Add to `server.cfg`:

```cfg
ensure spz-lib
ensure spz-vehicles
ensure spz-carspawner
```

---

## Commands

| Command | Args | Description |
|---|---|---|
| `/car` | None | Opens the Vehicle Depot NUI |
| `/car` | `[model]` | Spawns a specific vehicle model immediately |
| `/dv` | None | Despawns the player's active vehicle |

---

<div align="center">

*Part of the [SPiceZ-Core](https://github.com/SPiceZ-Core) ecosystem*

**[Docs](https://github.com/SPiceZ-Core/spz-docs) · [Discord](https://discord.gg/) · [Issues](https://github.com/SPiceZ-Core/spz-carspawner/issues)**

</div>
