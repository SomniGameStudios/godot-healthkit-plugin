extends Control

@onready var result_label: Label = $VBoxContainer/ResultLabel

func _on_today_steps_pressed() -> void:
	HealthKit.run_today_steps_query()
	# HealthKit queries are async — wait briefly then read
	await get_tree().create_timer(1.0).timeout
	var steps = HealthKit.get_today_steps()
	result_label.text = "Today's steps: %d" % steps

func _on_total_steps_pressed() -> void:
	HealthKit.run_total_steps_query()
	await get_tree().create_timer(1.0).timeout
	var steps = HealthKit.get_total_steps()
	result_label.text = "Total steps: %d" % steps

func _on_period_steps_pressed() -> void:
	HealthKit.run_period_steps_query(7)
	await get_tree().create_timer(1.0).timeout
	var data = HealthKit.get_period_steps_dict()
	var text = "Steps (last 7 days):\n"
	var keys = data.keys()
	keys.sort()
	for date in keys:
		text += "%s: %d\n" % [date, data[date]]
	result_label.text = text

func _on_track_permission_pressed() -> void:
	HealthKit.request_track_permission()
	result_label.text = "Tracking permission requested"

func _on_debug_mode_pressed() -> void:
	var is_debug = HealthKit.is_admob_debug_or_release()
	result_label.text = "AdMob debug mode: %s" % str(is_debug)
