# spz-carspawner

> Freeroam car spawner.

![version](https://img.shields.io/badge/version-1.5.0-ff6200) ![SPiceZ-Core](https://img.shields.io/badge/SPiceZ--Core-beta-18181b)

## Overview

Opens a searchable garage (`F5`) with every car, filtered by class, including add-ons. Freeroam only.

## Features

- Search and class filter
- Add-on cars included
- `/car <model>` to spawn directly

## Requirements

| Resource | Type |
|---|---|
| `ox_lib` | third-party |
| `spz-vehicles` | SPiceZ module |

## Installation

Included in the [txAdmin recipe](https://github.com/SPiceZ21/spz-txrecipe). Manual install:

1. Download `spz-carspawner` from GitHub (latest release, or the repository) into your `resources` folder.
2. Add to `server.cfg`, after its requirements:

```cfg
ensure spz-carspawner
```

## Commands

| Command | Who | Description |
|---|---|---|
| `/car` | player | Open the spawner, or `/car <model>` |
| `/dv` | player | Delete your vehicle |

## Key binds

Rebindable in **Settings → Key Bindings → FiveM**.

| Action | Default |
|---|---|
| Open Car Spawner | `F5` |

---

Part of **SPiceZ-Core** — [documentation](https://github.com/SPiceZ21/Docs) · [all modules](https://github.com/SPiceZ21/Docs/blob/main/modules/README.md)
