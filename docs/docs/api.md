---
sidebar_position: 2
---

# GDScript API

The plugin registers a singleton accessible via `Engine.get_singleton()`. It is recommended to check for its existence before trying to use its methods.

### GodotHealthKit

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
