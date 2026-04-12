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

extends Control

@onready var result_label: Label = $SafeAreaContainer/ScrollContainer/VBoxContainer/ResultLabel

func _ready() -> void:
	HealthKit.permission_result.connect(_on_permission_result)
	HealthKit.steps_updated.connect(_on_steps_updated)
	HealthKit.pedometer_steps_updated.connect(_on_pedometer_steps_updated)
	HealthKit.pedometer_error.connect(_on_pedometer_error)
	result_label.add_theme_color_override("font_color", Color.BLACK)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		_on_hk_today_steps()

# --- Signal handlers ---

func _on_permission_result(granted: bool) -> void:
	if granted:
		result_label.text = "HK Permission: Granted"
	else:
		result_label.add_theme_color_override("font_color", Color.RED)
		result_label.text = "HK Permission: Likely denied.\nHealth App > Profile > Apps & Services > %s" % _get_app_name()

func _on_steps_updated(steps: int) -> void:
	result_label.text = "HK Observer: %d steps" % steps

func _on_pedometer_steps_updated(steps: int) -> void:
	result_label.text = "CM Pedometer: %d steps" % steps

func _on_pedometer_error(reason: String) -> void:
	result_label.add_theme_color_override("font_color", Color.RED)
	result_label.text = "CM Error: %s" % reason

# --- HealthKit actions ---

func _on_hk_request_permission() -> void:
	HealthKit.request_permission()
	result_label.text = "Requesting HealthKit permission..."

func _on_hk_check_status() -> void:
	var available := HealthKit.is_health_data_available()
	var hk_status := HealthKit.get_permission_status()
	result_label.add_theme_color_override("font_color", Color.BLACK)

	var status_str := HealthKit.get_permission_status_string(hk_status)

	if hk_status == HealthKit.AuthorizationStatus.NOT_DETERMINED:
		result_label.text = "HK Available: %s\nHK Status: %s\nTap 'Request Permission' first" % [str(available).to_upper(), status_str]
		return

	result_label.text = "Verifying read access..."
	HealthKit.run_today_steps_query()
	var steps: int = await HealthKit.today_steps_ready

	if steps == 0:
		result_label.add_theme_color_override("font_color", Color.ORANGE)
		result_label.text = "HK Status: %s\nToday: 0 steps\n(Could be no data or permission denied)\nHealth App > Profile > Apps & Services > %s" % [status_str, _get_app_name()]
	else:
		result_label.add_theme_color_override("font_color", Color.SEA_GREEN)
		result_label.text = "HK Status: %s\nToday: %d steps" % [status_str, steps]

func _on_hk_today_steps() -> void:
	HealthKit.run_today_steps_query()
	var steps: int = await HealthKit.today_steps_ready
	result_label.text = "Today's steps: %d" % steps

func _on_hk_total_steps() -> void:
	HealthKit.run_total_steps_query()
	var steps: int = await HealthKit.total_steps_ready
	result_label.text = "Total steps: %d" % steps

func _on_hk_period_steps() -> void:
	HealthKit.run_period_steps_query(7)
	var data: Dictionary = await HealthKit.period_steps_ready
	var text := "Steps (last 7 days):\n"
	var keys := data.keys()
	keys.sort()
	for date in keys:
		text += "%s: %d\n" % [date, data[date]]
	result_label.text = text

func _on_hk_start_observer() -> void:
	HealthKit.start_step_observer()
	result_label.text = "HK Observer started (5-60s updates)"

func _on_hk_stop_observer() -> void:
	HealthKit.stop_step_observer()
	result_label.text = "HK Observer stopped"

func _on_hk_open_settings() -> void:
	HealthKit.open_settings()
	result_label.text = "Opening Health App...\nNavigate to: Profile > Apps & Services > %s" % _get_app_name()

# --- CoreMotion Pedometer actions ---

func _on_cm_check_status() -> void:
	var motion_status := HealthKit.get_pedometer_permission_status()
	var pedometer_hw := HealthKit.is_pedometer_available()
	result_label.add_theme_color_override("font_color", Color.BLACK)

	var status_str := "Unknown"
	match motion_status:
		HealthKit.MotionAuthorizationStatus.NOT_DETERMINED:
			status_str = "Not Determined (will prompt on start)"
		HealthKit.MotionAuthorizationStatus.RESTRICTED:
			status_str = "Restricted (device policy)"
		HealthKit.MotionAuthorizationStatus.DENIED:
			status_str = "Denied (enable in Settings > Privacy > Motion & Fitness)"
		HealthKit.MotionAuthorizationStatus.AUTHORIZED:
			status_str = "Authorized"

	result_label.text = "CM Permission: %s\nPedometer HW: %s" % [status_str, str(pedometer_hw).to_upper()]

func _on_cm_start_pedometer() -> void:
	var motion_status := HealthKit.get_pedometer_permission_status()
	if motion_status == HealthKit.MotionAuthorizationStatus.DENIED:
		result_label.add_theme_color_override("font_color", Color.RED)
		result_label.text = "Motion denied.\nSettings > Privacy > Motion & Fitness"
		return
	if motion_status == HealthKit.MotionAuthorizationStatus.RESTRICTED:
		result_label.add_theme_color_override("font_color", Color.RED)
		result_label.text = "Motion restricted by device policy."
		return
	HealthKit.start_pedometer_observer()
	result_label.text = "CM Pedometer started. Walk!"

func _on_cm_stop_pedometer() -> void:
	HealthKit.stop_pedometer_observer()
	result_label.text = "CM Pedometer stopped"

func _get_app_name() -> String:
	return ProjectSettings.get_setting("application/config/name", "this app")
