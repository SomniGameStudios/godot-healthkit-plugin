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

# plugin.gd
@tool
extends EditorPlugin

const SINGLETON_NAME := "HealthKit"
const SINGLETON_PATH := "res://addons/healthkit_plugin/health_kit.gd"

var export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	# Add autoload singleton
	add_autoload_singleton(SINGLETON_NAME, SINGLETON_PATH)

	# Load the export plugin script safely
	var ExportScript = load("res://addons/healthkit_plugin/export_plugin.gd")
	if ExportScript:
		export_plugin = ExportScript.new()
		add_export_plugin(export_plugin)
		print("HealthKit: Export plugin registered.")
	else:
		printerr("HealthKit: Could not load export script.")

func _exit_tree() -> void:
	# Remove autoload singleton
	remove_autoload_singleton(SINGLETON_NAME)

	if export_plugin:
		remove_export_plugin(export_plugin)
		export_plugin = null
