extends Node
## HealthKit autoload — wraps the GodotHealthKit singleton.
## On non-iOS platforms, returns mock data for editor testing.

signal permission_result(granted: bool)
signal steps_updated(steps: int)

var _healthkit_plugin = null
var _is_ios: bool = false

func _ready() -> void:
	_is_ios = OS.get_name() == "iOS"

	if _is_ios:
		if Engine.has_singleton("GodotHealthKit"):
			_healthkit_plugin = Engine.get_singleton("GodotHealthKit")
			_healthkit_plugin.connect("permission_result", Callable(self, "_on_permission_result"))
			_healthkit_plugin.connect("steps_updated", Callable(self, "_on_steps_updated"))
			print("HealthKit: iOS plugin initialized")
		else:
			printerr("HealthKit: GodotHealthKit singleton not found")
	else:
		print("HealthKit: Non-iOS platform, using mock data")

func _on_permission_result(granted: bool) -> void:
	permission_result.emit(granted)

func _on_steps_updated(steps: int) -> void:
	steps_updated.emit(steps)

# --- HealthKit Methods ---

func request_permission() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.request_permission()
	else:
		call_deferred("emit_signal", "permission_result", true)

func get_permission_status() -> int:
	if _healthkit_plugin:
		return _healthkit_plugin.get_permission_status()
	return 2 # mock authorized (HKAuthorizationStatusSharingAuthorized)

func is_health_data_available() -> bool:
	if _healthkit_plugin:
		return _healthkit_plugin.is_health_data_available()
	return true

func start_step_observer() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.start_step_observer()

func stop_step_observer() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.stop_step_observer()

func run_today_steps_query() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.run_today_steps_query()

func get_today_steps() -> int:
	if _healthkit_plugin:
		return _healthkit_plugin.get_today_steps()
	return 1234  # Mock data

func run_total_steps_query() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.run_total_steps_query()

func get_total_steps() -> int:
	if _healthkit_plugin:
		return _healthkit_plugin.get_total_steps()
	return 56789  # Mock data

func run_period_steps_query(days: int) -> void:
	if _healthkit_plugin:
		_healthkit_plugin.run_period_steps_query(days)

func get_period_steps_dict() -> Dictionary:
	if _healthkit_plugin:
		return _healthkit_plugin.get_period_steps_dict()
	# Mock data
	var mock := {}
	var today := Time.get_date_dict_from_system()
	for i in range(7):
		var date := Time.get_date_string_from_unix_time(
			Time.get_unix_time_from_datetime_dict(today) - i * 86400
		)
		mock[date] = randi_range(2000, 12000)
	return mock
