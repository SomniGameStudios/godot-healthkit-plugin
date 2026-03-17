extends Node
## HealthKit autoload — wraps the iosHealthKit and iosNative singletons.
## On non-iOS platforms, returns mock data for editor testing.

var _healthkit_plugin = null
var _native_plugin = null
var _is_ios: bool = false

func _ready() -> void:
	_is_ios = OS.get_name() == "iOS"

	if _is_ios:
		if Engine.has_singleton("iosHealthKit"):
			_healthkit_plugin = Engine.get_singleton("iosHealthKit")
			print("HealthKit: iOS plugin initialized")
		else:
			printerr("HealthKit: iosHealthKit singleton not found")

		if Engine.has_singleton("iosNative"):
			_native_plugin = Engine.get_singleton("iosNative")
			print("HealthKit: iosNative plugin initialized")
		else:
			printerr("HealthKit: iosNative singleton not found")
	else:
		print("HealthKit: Non-iOS platform, using mock data")

# --- HealthKit Methods ---

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

# --- Native Methods ---

func request_track_permission() -> void:
	if _native_plugin:
		_native_plugin.request_track_permission()
	else:
		print("HealthKit: Track permission (mock - non-iOS)")

func is_admob_debug_or_release() -> bool:
	if _native_plugin:
		return _native_plugin.is_admob_debug_or_release() == 1
	return false
