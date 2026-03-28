extends Control

@onready var result_label: Label = $SafeAreaContainer/VBoxContainer/ResultLabel

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
