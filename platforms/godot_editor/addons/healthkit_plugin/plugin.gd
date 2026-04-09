# plugin.gd
@tool
extends EditorPlugin

var export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	# Load the export plugin script safely
	var ExportScript = load("res://addons/healthkit_plugin/export_plugin.gd")
	if ExportScript:
		export_plugin = ExportScript.new()
		add_export_plugin(export_plugin)
		print("HealthKit: Export plugin registered.")
	else:
		printerr("HealthKit: Could not load export script.")

func _exit_tree() -> void:
	if export_plugin:
		remove_export_plugin(export_plugin)
		export_plugin = null
