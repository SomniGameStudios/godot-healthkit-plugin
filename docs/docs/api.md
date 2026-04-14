---
sidebar_position: 2
---

# GDScript API

The plugin provides a GDScript wrapper named `HealthKit`, which is automatically registered as an Autoload singleton when the plugin is enabled. It is the recommended way to interact with the plugin as it handles platform checks and provides mock data for non-iOS platforms.

### Singleton: HealthKit

This is the interface for interacting with the plugin. It wraps the native `GodotHealthKit` singleton under the hood.

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

### Methods

| Method | Returns | Description |
| :--- | :--- | :--- |
| `request_permission()` | `void` | Requests permission to read HealthKit data. |
| `get_permission_status()` | `int` | Returns the `AuthorizationStatus`. |
| `get_permission_status_string(status: int)` | `String` | Returns a human-readable string for the given `AuthorizationStatus`. |
| `is_health_data_available()` | `bool` | Checks if HealthKit is available on the device. |
| `start_step_observer()` | `void` | Starts background observation for step count changes. |
| `stop_step_observer()` | `void` | Stops background step observation. |
| `is_pedometer_available()` | `bool` | Checks if the device supports CMPedometer. |
| `get_pedometer_permission_status()` | `int` | Returns the `MotionAuthorizationStatus`. |
| `start_pedometer_observer()` | `void` | Starts real-time pedometer tracking. |
| `stop_pedometer_observer()` | `void` | Stops real-time pedometer tracking. |
| `get_live_pedometer_steps()` | `int` | Returns the number of steps tracked since the pedometer was started. |
| `run_today_steps_query()` | `void` | Requests the total step count for today. Emits `today_steps_ready` when done. |
| `get_today_steps()` | `int` | Returns the cached step count for today (after query finishes). |
| `run_total_steps_query()` | `void` | Requests the all-time total step count. Emits `total_steps_ready` when done. |
| `get_total_steps()` | `int` | Returns the cached all-time step count (after query finishes). |
| `run_period_steps_query(days: int)` | `void` | Requests daily step counts for the past `days`. Emits `period_steps_ready`. |
| `get_period_steps_dict()` | `Dictionary` | Returns the cached dictionary of period steps (e.g., `{"2026-04-13": 5000}`). |
| `open_settings()` | `void` | Opens the app settings (useful if permissions were denied). |

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
