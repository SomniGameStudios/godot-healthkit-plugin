# export_plugin.gd
@tool
extends EditorExportPlugin

var export_path: String = ""

func _get_name() -> String:
	return "HealthKitExportPlugin"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	if features.has("ios"):
		export_path = path
		print("HealthKit: Exporting to ", export_path)

func _export_end() -> void:
	if export_path.is_empty() or not export_path.ends_with(".xcodeproj"):
		return

	var project_dir := export_path.get_base_dir()
	var project_name := export_path.get_file().get_basename()
	
	# Recursively search for .entitlements files
	var entitlements_files := _find_files_with_extension(project_dir, "entitlements")
	if entitlements_files.is_empty():
		# Fallback: maybe it's just godot_ios.entitlements
		var fallback := project_dir.path_join("godot_ios").path_join("godot_ios.entitlements")
		if FileAccess.file_exists(fallback):
			entitlements_files.append(fallback)
	
	if entitlements_files.is_empty():
		printerr("HealthKit: Could not find any .entitlements file in: ", project_dir)
	else:
		for path in entitlements_files:
			_patch_xml_file(path, "com.apple.developer.healthkit", _get_health_block())

	# Also check Info.plist for privacy descriptions
	var plist_files := _find_files_with_extension(project_dir, "plist")
	for path in plist_files:
		if path.get_file() == "Info.plist" or path.get_file() == project_name + "-Info.plist":
			_patch_xml_file(path, "NSHealthShareUsageDescription", _get_privacy_block())

func _get_health_block() -> String:
	return "\t<key>com.apple.developer.healthkit</key>\n\t<true/>\n\t<key>com.apple.developer.healthkit.background-delivery</key>\n\t<true/>\n"

func _get_privacy_block() -> String:
	return "\t<key>NSHealthShareUsageDescription</key>\n\t<string>Access to your health data is required for this plugin demo.</string>\n\t<key>NSHealthUpdateUsageDescription</key>\n\t<string>Access to your health data is required for this plugin demo.</string>\n\t<key>NSMotionUsageDescription</key>\n\t<string>Real-time motion tracking is used for live step updates.</string>\n\t<key>UIBackgroundModes</key>\n\t<array>\n\t\t<string>health-update</string>\n\t</array>\n\t<key>LSApplicationQueriesSchemes</key>\n\t<array>\n\t\t<string>x-apple-health</string>\n\t</array>\n"

func _find_files_with_extension(path: String, extension: String) -> Array:
	var results := []
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					results.append_array(_find_files_with_extension(path.path_join(file_name), extension))
			elif file_name.ends_with("." + extension):
				results.append(path.path_join(file_name))
			file_name = dir.get_next()
	return results

func _patch_xml_file(path: String, search_key: String, block_to_inject: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if not file:
		return

	var content := file.get_as_text()
	if search_key in content:
		file.close()
		return

	# Inject before the final </dict>
	var new_content := content.replace("</dict>", block_to_inject + "</dict>")
	file.store_string(new_content)
	file.close()
	print("HealthKit: Patched ", path.get_file(), " successfully.")
