---
sidebar_position: 2
---

# GDScript API

The plugin provides a GDScript wrapper named `HealthKit`, which is automatically registered as an Autoload singleton when the plugin is enabled. It is the recommended way to interact with the plugin as it handles platform checks and provides mock data for non-iOS platforms.

### Singleton: HealthKit (GDScript Wrapper)

This is the recommended interface. It wraps the native `GodotHealthKit` singleton.

```gdscript
func _ready() -> void:
    # Signals
    HealthKit.permission_result.connect(_on_permission_result)
    HealthKit.steps_updated.connect(_on_steps_updated)
    HealthKit.today_steps_ready.connect(_on_today_steps_ready)

    # Request permission
    HealthKit.request_permission()

    # Query today's steps
    HealthKit.run_today_steps_query()
    var steps: int = await HealthKit.today_steps_ready
    print("Today's steps: ", steps)
```

### Native Singleton: GodotHealthKit

If you prefer to use the native C++ singleton directly:

```gdscript
if Engine.has_singleton("GodotHealthKit"):
    var hk = Engine.get_singleton("GodotHealthKit")
    # ... use native methods directly
```

### Signals

| Signal | Description |
| :--- | :--- |
| `permission_result(granted: bool)` | Emitted after `request_permission()` completes. |
| `steps_updated(steps: int)` | Emitted when `HKObserverQuery` detects a change in today's step count. |
| `today_steps_ready(steps: int)` | Emitted when `run_today_steps_query()` completes. |
| `total_steps_ready(steps: int)` | Emitted when `run_total_steps_query()` completes. |
| `period_steps_ready(steps_dict: Dictionary)` | Emitted when `run_period_steps_query()` completes. |
| `pedometer_steps_updated(steps: int)` | Emitted when the real-time pedometer detects new steps since it was started. |
| `pedometer_error(reason: String)` | Emitted if the pedometer encounters an error. |

### Enums

#### AuthorizationStatus (HealthKit)
- `NOT_DETERMINED = 0`
- `SHARING_DENIED = 1`
- `SHARING_AUTHORIZED = 2`

#### MotionAuthorizationStatus (CoreMotion)
- `NOT_DETERMINED = 0`
- `RESTRICTED = 1`
- `DENIED = 2`
- `AUTHORIZED = 3`
