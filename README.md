# spz-carspawner

> ox_lib vehicle spawn menu · `v1.1.0`

## Overview

`spz-carspawner` is a lightweight spawn menu built on `ox_lib`. Vehicles and classes come
from the [spz-vehicles](../spz-vehicles/README.md) registry, and the server validates every
spawn request.

Race classes only — Coupes, Muscle, Sports Classics, Sports, Super and Open Wheel.
Civilian, service, utility and prop vehicles are not spawnable.

## Structure

| Side | File | Purpose |
|---|---|---|
| Client | `client/main.lua` | Menu, spawn requests |
| Server | `server/main.lua` | Spawn authority and validation |

## Commands

| Command | Effect |
|---|---|
| `/car [model]` | Spawn a vehicle, or open the menu with no argument |
| `/dv` | Delete the vehicle you are in or near |

## Dependencies

`ox_lib` · `spz-vehicles`

---

Part of [SPiceZ-Core](../README.md) · GPL-3.0
