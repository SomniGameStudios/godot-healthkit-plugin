---
sidebar_position: 1
slug: /
---

# Godot HealthKit Plugin

A Godot 4 iOS plugin that provides native HealthKit step counting and motion tracking for iOS games.

## Features

- **HealthKit** — Query today's steps, total steps, and daily step breakdowns
- **Motion Tracking** — Real-time step counting via CMPedometer

## Quick Start

1. Download the latest release zip
2. Extract the downloaded zip and move the `addons/` folder into your Godot project's root directory:
   ```text
   your-godot-project/
     addons/
       healthkit_plugin/
         plugin.cfg
         plugin.gd
         export_plugin.gd
         health_kit.gd
         HealthKitPlugin.gdip
         HealthKitPlugin/
           bin/
             HealthKitPlugin.debug.xcframework/
             HealthKitPlugin.release.xcframework/
         demo/
           scenes/
             main.tscn
           scripts/
             main.gd
             ...
   ```
3. In Godot, go to **Project \> Project Settings \> Plugins** and enable the **HealthKit Plugin**
4. In Godot, go to **Project \> Export \> iOS** and enable the **HealthKitPlugin** plugin
5. The plugin auto-injects required permissions (HealthKit, Motion) into your export

## Demo Project

The `platforms/godot_editor/` directory contains a minimal Godot project that demonstrates all plugin APIs. It provides mock data when running on non-iOS platforms for easy editor testing.

## Project Structure

```text
godot-healthkit-plugin/
  platforms/
    ios/                     # iOS Plugin source
      HealthKitPlugin/       # Native Objective-C++ code
      HealthKitPlugin.xcodeproj/
      HealthKitPlugin.gdip   # Plugin descriptor
      scripts/               # Build automation
    godot_editor/            # Demo Godot project
  docs/                      # Documentation
  .github/workflows/         # CI/CD
```
