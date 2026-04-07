<div align="center">

<img src="https://raw.githubusercontent.com/htl-stp-ecer/.github/main/profile/raccoon-logo.svg" alt="StpVelox" width="100"/>

# StpVelox (BotUI)

**The Flutter desktop environment for the KIPR Wombat — dashboard, programs, sensors, and more.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](COPYING)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi%20ARM64-A22846?logo=raspberrypi&logoColor=white)
![Display](https://img.shields.io/badge/Display-800x480-555)

> 📖 **Full documentation at [raccoon-docs.pages.dev](https://raccoon-docs.pages.dev/)**

</div>

---

StpVelox is the graphical environment that runs directly on the [KIPR Wombat](https://www.kipr.org/kipr/hardware-software) controller. It replaces the default Wombat UI with a fast, touch-friendly Flutter interface purpose-built for Botball competition — real-time sensor graphs, a program runner with live terminal output, WiFi management, and a camera feed, all on an 800×480 display.

---

## Features

| Screen | What it does |
|:-------|:-------------|
| **Dashboard** | Live sensor overview grid — IMU, analog/digital ports, battery |
| **Programs** | Browse, launch, and monitor robot programs with a live terminal |
| **Sensors** | Real-time charts for gyro, accelerometer, magnetometer, and analog inputs |
| **Camera** | Live camera feed from the robot's vision system |
| **WiFi** | Scan, connect, and manage networks via Linux NetworkManager |
| **Settings** | Device config, touch calibration for the embedded display |
| **Robot Face** | Animated face for the robot |

---

## Building & deploying

StpVelox uses [FVM](https://fvm.app/) for Flutter version pinning and [flutterpi_tool](https://pub.dev/packages/flutterpi_tool) for ARM64 cross-compilation.

### Prerequisites

```bash
# Install FVM
dart pub global activate fvm
fvm install   # picks up version from .fvmrc

# Activate flutterpi_tool
dart pub global activate flutterpi_tool
```

### Build & deploy to Pi

```bash
# Build release + deploy to Pi in one step
DEPLOY_HOST=<your-pi-ip> bash deploy.sh
```

### Debug (profile mode on connected Pi)

```bash
bash debug.sh
```

### Build only (output in build/)

```bash
bash build.sh
```

The build script runs `build_runner` for code generation (Riverpod, Freezed, JSON serialization), then cross-compiles for `arm64 / pi3`.

---

## Architecture

StpVelox follows **Clean Architecture** with three layers and [Riverpod](https://riverpod.dev/) for state management throughout.

```
lib/
├── core/           # DI (GetIt), routing (go_router), theme, shared utilities
├── features/       # One folder per feature (dashboard, program, sensors, wifi, ...)
│   └── <feature>/
│       ├── domain/       # Entities, repository interfaces, use cases
│       ├── data/         # Repository implementations, data sources
│       └── presentation/ # Riverpod providers, screens, widgets
├── shared/         # Shared widgets and helpers used across features
└── main.dart
```

**Hardware access** goes through `KiprPlugin` — a native method channel that exposes motor/servo control, sensor reads (IMU, analog, digital), and battery monitoring from the underlying KIPR C library.

**Program execution** uses a pseudoterminal so program stdout/stderr stream live into the terminal widget (`xterm`).

---

## Requirements

- [FVM](https://fvm.app/) — Flutter version manager
- Dart SDK ^3.5.4
- `flutterpi_tool` for ARM64 builds
- KIPR Wombat with Raspberry Pi (ARM64, 800×480 display)

---

## Part of RaccoonOS

| Repository | What it is |
|:-----------|:-----------|
| [raccoon-lib](https://github.com/htl-stp-ecer/raccoon-lib) | Core robotics library |
| [raccoon-cli](https://github.com/htl-stp-ecer/raccoon-cli) | Dev toolchain — scaffolding, `raccoon run` |
| [raccoon-transport](https://github.com/htl-stp-ecer/raccoon-transport) | LCM messaging layer |
| [documentation](https://raccoon-docs.pages.dev/) | Full platform docs |

---

## License

Copyright (C) 2026 Tobias Madlberger  
Licensed under the GNU General Public License v3.0 — see [COPYING](COPYING) for details.
