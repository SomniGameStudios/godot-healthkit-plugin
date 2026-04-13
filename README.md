# Godot HealthKit Plugin

A Godot 4 iOS plugin that provides native HealthKit step counting and motion tracking for iOS games.

[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://SomniGameStudios.github.io/godot-healthkit-plugin/)
[![GitHub stars](https://img.shields.io/github/stars/SomniGameStudios/godot-healthkit-plugin.svg?style=social&label=Star)](https://github.com/SomniGameStudios/godot-healthkit-plugin)

## Features

- **HealthKit** — Query today's steps, total steps, and daily step breakdowns
- **Motion Tracking** — Real-time step counting via CMPedometer
- **Mock Data** — Seamless editor testing with mock data for non-iOS platforms
- **Auto-Injection** — Required permissions are automatically added to your iOS export

## Documentation

Full documentation is available at [https://SomniGameStudios.github.io/godot-healthkit-plugin/](https://SomniGameStudios.github.io/godot-healthkit-plugin/).

- [Quick Start](https://SomniGameStudios.github.io/godot-healthkit-plugin/)
- [GDScript API](https://SomniGameStudios.github.io/godot-healthkit-plugin/api)
- [Building from Source](https://SomniGameStudios.github.io/godot-healthkit-plugin/building)

## Quick Start (Pre-built)

1. Download the latest release zip.
2. Extract and move the `addons/healthkit_plugin` folder into your Godot project's `addons/` directory.
3. In Godot, enable the plugin in **Project > Project Settings > Plugins**.
4. In **Project > Export > iOS**, enable the **HealthKitPlugin** in the Plugins section.

## Demo Project

The `platforms/godot_editor/` directory contains a minimal Godot project that demonstrates all plugin APIs.

## License

MIT License. See [LICENSE](LICENSE) for details.
