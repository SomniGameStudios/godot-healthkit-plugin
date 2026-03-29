extends Control

@onready var result_label: Label = $SafeAreaContainer/VBoxContainer/ResultLabel

func _ready() -> void:
	HealthKit.permission_result.connect(_on_permission_result)
	HealthKit.steps_updated.connect(_on_steps_updated)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		# Automatically refresh when returning from Settings app
		_on_today_steps_pressed()

func _on_permission_result(granted: bool) -> void:
	result_label.text = "Permission granted: " + str(granted)

func _on_steps_updated(steps: int) -> void:
	result_label.text = "Live steps update: %d" % steps

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

func _on_request_permission_pressed() -> void:
	HealthKit.request_permission()
	result_label.text = "Requesting permission..."

func _on_start_observer_pressed() -> void:
	HealthKit.start_step_observer()
	result_label.text = "Observer started. Walk to see live updates!"

func _on_check_status_pressed() -> void:
	var available = HealthKit.is_health_data_available()
	var status = HealthKit.get_permission_status()
	result_label.text = "Available: %s\nStatus Code: %d" % [str(available), status]

func _on_manage_permissions_pressed() -> void:
	HealthKit.open_settings()
	result_label.text = "Opening System Settings..."
