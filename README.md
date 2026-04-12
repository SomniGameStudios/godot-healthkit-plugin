# Godot HealthKit Plugin

A Godot 4 iOS plugin that provides native HealthKit step counting and App Tracking Transparency for iOS games.

## Features

- **HealthKit** — Query today's steps, total steps, and daily step breakdowns
- **App Tracking Transparency** — Request IDFA tracking permission (iOS 14+)
- **AdMob debug flag** — Check if running in debug or release mode

## Quick Start

1. Download the latest release zip
2. Extract the downloaded zip and move the `addons/` folder into your Godot project's root directory:
   ```
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
             ...   ```
3. In Godot, go to **Project > Project Settings > Plugins** and enable the **HealthKit Plugin**
4. In Godot, go to **Project > Export > iOS** and enable the **HealthKitPlugin** plugin
5. The plugin auto-injects required permissions (HealthKit, Tracking) into your export

## GDScript API

The plugin registers a singleton accessible via `Engine.get_singleton()`:

### `GodotHealthKit`

```gdscript
if Engine.has_singleton("GodotHealthKit"):
    var hk = Engine.get_singleton("GodotHealthKit")

    # Connect to signals
    hk.connect("permission_result", Callable(self, "_on_permission_result"))
    hk.connect("steps_updated", Callable(self, "_on_steps_updated"))

    # Request permission
    hk.request_permission()

    # Check permission and availability
    var is_available: bool = hk.is_health_data_available()
    var status: int = hk.get_permission_status()

    # Start real-time observer and background delivery
    hk.start_step_observer()

    # Async snapshot queries (call first, then read result after ~1s)
    hk.run_today_steps_query()
    hk.run_total_steps_query()
    hk.run_period_steps_query(7)  # last 7 days

    # Read cached results
    var today: int = hk.get_today_steps()
    var total: int = hk.get_total_steps()
    var period: Dictionary = hk.get_period_steps_dict()  # {"2026-03-15": 5432, ...}
```

## Building from Source

Requires macOS with Xcode and Python (for scons).

```bash
# Install scons
pip install scons

# Build for Godot 4.6.1
./platforms/ios/scripts/build.sh 4.6.1
```

This will:
1. Download Godot source (for headers only)
2. Generate headers with scons
3. Build Debug + Release static libraries with xcodebuild
4. Create `.xcframework` bundles
5. Copy output to `platforms/godot_editor/addons/healthkit_plugin/`

Build output is in `platforms/ios/build/output/`.

## Demo Project

The `platforms/godot_editor/` directory contains a minimal Godot project that demonstrates all plugin APIs. It provides mock data when running on non-iOS platforms for easy editor testing.

## Project Structure

```
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

## Troubleshooting

### `platform_config.h` not found
Run the build script with the correct Godot version. The headers must match your Godot version.

### Linker errors with `ClassDB::bind_method`
Ensure you're using the correct Debug/Release binary for your export type. The xcframework format handles this automatically.

## License

See [LICENSE](LICENSE) for details.
