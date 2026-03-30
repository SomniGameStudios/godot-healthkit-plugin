extends Control

@onready var result_label: Label = $SafeAreaContainer/ScrollContainer/VBoxContainer/ResultLabel

func _ready() -> void:
	HealthKit.permission_result.connect(_on_permission_result)
	HealthKit.steps_updated.connect(_on_steps_updated)
	# Set default color for light theme
	result_label.add_theme_color_override("font_color", Color.BLACK)

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
	var steps: int = await HealthKit.today_steps_ready
	result_label.text = "Today's steps: %d" % steps

func _on_total_steps_pressed() -> void:
	HealthKit.run_total_steps_query()
	var steps: int = await HealthKit.total_steps_ready
	result_label.text = "Total steps: %d" % steps

func _on_period_steps_pressed() -> void:
	HealthKit.run_period_steps_query(7)
	var data: Dictionary = await HealthKit.period_steps_ready
	var text := "Steps (last 7 days):\n"
	var keys := data.keys()
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
	var available := HealthKit.is_health_data_available()
	var status = HealthKit.get_permission_status()
	result_label.add_theme_color_override("font_color", Color.BLACK)
	
	if status == HealthKit.AuthorizationStatus.NOT_DETERMINED:
		result_label.text = "HealthKit Available: %s\nStatus: Not Requested / Determined" % str(available).to_upper()
		return
		
	result_label.text = "HealthKit Available: %s\nVerifying read access..." % str(available).to_upper()
	
	HealthKit.run_today_steps_query()
	var steps: int = await HealthKit.today_steps_ready
	
	result_label.text = "HealthKit Available: %s\nRead Access: Granted\nToday's Steps: %d" % [str(available).to_upper(), steps]
	result_label.add_theme_color_override("font_color", Color.SEA_GREEN)

func _on_manage_permissions_pressed() -> void:
	HealthKit.open_settings()
	result_label.text = "Opening System Settings..."
