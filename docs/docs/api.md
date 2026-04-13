---
sidebar_position: 2
---

# GDScript API

The plugin registers a singleton accessible via `Engine.get_singleton("GodotHealthKit")`. It is recommended to check for its existence before trying to use its methods.

Alternatively, if you use the provided plugin's GDScript wrapper, it handles the singleton check and provides a more idiomatic GDScript interface with mock data for non-iOS platforms.

### Singleton: GodotHealthKit

```gdscript
if Engine.has_singleton("GodotHealthKit"):
    var hk = Engine.get_singleton("GodotHealthKit")

    # Connect to signals
    hk.connect("permission_result", _on_permission_result)
    hk.connect("steps_updated", _on_steps_updated)
    hk.connect("today_steps_ready", _on_today_steps_ready)
    hk.connect("total_steps_ready", _on_total_steps_ready)
    hk.connect("period_steps_ready", _on_period_steps_ready)
    hk.connect("pedometer_steps_updated", _on_pedometer_steps_updated)
    hk.connect("pedometer_error", _on_pedometer_error)

    # HealthKit Methods
    if hk.is_health_data_available():
        hk.request_permission()
        var status: int = hk.get_permission_status()
        
        # Async queries (listen for *_ready signals)
        hk.run_today_steps_query()
        hk.run_total_steps_query()
        hk.run_period_steps_query(7)  # last 7 days

        # Cached results (updated after queries or via observer)
        var today: int = hk.get_today_steps()
        var total: int = hk.get_total_steps()
        var period: Dictionary = hk.get_period_steps_dict()

        # Real-time observer (triggers steps_updated signal)
        hk.start_step_observer()
        # hk.stop_step_observer()

    # Pedometer Methods (CoreMotion)
    if hk.is_pedometer_available():
        var p_status: int = hk.get_pedometer_permission_status()
        hk.start_pedometer_observer()
        var live_steps: int = hk.get_live_pedometer_steps()
        # hk.stop_pedometer_observer()

    # Utilities
    hk.open_settings()
    hk.refresh_health_store()
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
