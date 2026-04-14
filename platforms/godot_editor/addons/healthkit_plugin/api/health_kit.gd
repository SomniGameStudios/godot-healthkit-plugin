# MIT License
#
# Copyright (c) 2026 Somni Game Studios
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class_name HealthKitPlugin extends Node
## HealthKit autoload — wraps the GodotHealthKit singleton.
## On non-iOS platforms, returns mock data for editor testing.

signal permission_result(granted: bool)
signal steps_updated(steps: int)
signal pedometer_steps_updated(steps: int)
signal pedometer_error(reason: String)
signal today_steps_ready(steps: int)
signal total_steps_ready(steps: int)
signal period_steps_ready(steps_dict: Dictionary)

var _healthkit_plugin: Object = null
var _is_ios := false

enum AuthorizationStatus {
	NOT_DETERMINED = 0,
	SHARING_DENIED = 1,
	SHARING_AUTHORIZED = 2
}

## CMAuthorizationStatus — Apple's CoreMotion permission states
enum MotionAuthorizationStatus {
	NOT_DETERMINED = 0,
	RESTRICTED = 1,
	DENIED = 2,
	AUTHORIZED = 3
}

func get_permission_status_string(status: int) -> String:
	match status:
		AuthorizationStatus.NOT_DETERMINED:
			return "Not Determined"
		AuthorizationStatus.SHARING_DENIED:
			return "Sharing Denied (Read Status Hidden)"
		AuthorizationStatus.SHARING_AUTHORIZED:
			return "Sharing Authorized"
		_:
			return "Unknown (%d)" % status

func _ready() -> void:
	_is_ios = OS.get_name() == "iOS"

	if _is_ios:
		if Engine.has_singleton("GodotHealthKit"):
			_healthkit_plugin = Engine.get_singleton("GodotHealthKit")
			_healthkit_plugin.connect("permission_result", _on_permission_result)
			_healthkit_plugin.connect("steps_updated", _on_steps_updated)
			_healthkit_plugin.connect("pedometer_steps_updated", _on_pedometer_steps_updated)
			_healthkit_plugin.connect("pedometer_error", _on_pedometer_error)
			_healthkit_plugin.connect("today_steps_ready", _on_today_steps_ready)
			_healthkit_plugin.connect("total_steps_ready", _on_total_steps_ready)
			_healthkit_plugin.connect("period_steps_ready", _on_period_steps_ready)
			print("HealthKit: iOS plugin initialized")
		else:
			printerr("HealthKit: GodotHealthKit singleton not found")
	else:
		print("HealthKit: Non-iOS platform, using mock data")

func _on_permission_result(granted: bool) -> void:
	permission_result.emit(granted)

func _on_steps_updated(steps: int) -> void:
	steps_updated.emit(steps)

func _on_pedometer_steps_updated(steps: int) -> void:
	pedometer_steps_updated.emit(steps)

func _on_pedometer_error(reason: String) -> void:
	pedometer_error.emit(reason)

func _on_today_steps_ready(steps: int) -> void:
	today_steps_ready.emit(steps)

func _on_total_steps_ready(steps: int) -> void:
	total_steps_ready.emit(steps)

func _on_period_steps_ready(steps_dict: Dictionary) -> void:
	period_steps_ready.emit(steps_dict)

# --- HealthKit Methods ---

func request_permission() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.request_permission()
	else:
		permission_result.emit.call_deferred(true)

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

func is_pedometer_available() -> bool:
	if _healthkit_plugin:
		return _healthkit_plugin.is_pedometer_available()
	return false

func get_pedometer_permission_status() -> int:
	if _healthkit_plugin:
		return _healthkit_plugin.get_pedometer_permission_status()
	return MotionAuthorizationStatus.AUTHORIZED

func start_pedometer_observer() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.start_pedometer_observer()

func stop_pedometer_observer() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.stop_pedometer_observer()

func get_live_pedometer_steps() -> int:
	if _healthkit_plugin:
		return _healthkit_plugin.get_live_pedometer_steps()
	return 0

func run_today_steps_query() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.run_today_steps_query()
	else:
		today_steps_ready.emit.call_deferred(1234)

func open_settings() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.open_settings()
	else:
		print("HealthKit: Mock open_settings() called")

func get_today_steps() -> int:
	if _healthkit_plugin:
		return _healthkit_plugin.get_today_steps()
	return 1234

func run_total_steps_query() -> void:
	if _healthkit_plugin:
		_healthkit_plugin.run_total_steps_query()
	else:
		total_steps_ready.emit.call_deferred(56789)

func get_total_steps() -> int:
	if _healthkit_plugin:
		return _healthkit_plugin.get_total_steps()
	return 56789

func run_period_steps_query(days: int) -> void:
	if _healthkit_plugin:
		_healthkit_plugin.run_period_steps_query(days)
	else:
		var mock: Dictionary = {}
		var today: Dictionary = Time.get_date_dict_from_system()
		for i in range(days):
			var date: String = Time.get_date_string_from_unix_time(
				Time.get_unix_time_from_datetime_dict(today) - i * 86400
			)
			mock[date] = randi_range(2000, 12000)
		period_steps_ready.emit.call_deferred(mock)

func get_period_steps_dict() -> Dictionary:
	if _healthkit_plugin:
		return _healthkit_plugin.get_period_steps_dict()
	var mock: Dictionary = {}
	var today: Dictionary = Time.get_date_dict_from_system()
	for i in range(7):
		var date: String = Time.get_date_string_from_unix_time(
			Time.get_unix_time_from_datetime_dict(today) - i * 86400
		)
		mock[date] = randi_range(2000, 12000)
	return mock
