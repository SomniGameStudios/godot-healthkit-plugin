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

class_name HK_SafeAreaContainer extends MarginContainer

func _ready() -> void:
	apply_safe_area()
	get_tree().get_root().size_changed.connect(apply_safe_area)

func apply_safe_area() -> void:
	var top_margin = 0

	if OS.has_feature("mobile"):
		var safe_area = DisplayServer.get_display_safe_area()
		var window_position = DisplayServer.window_get_position()
		var relative_position = Vector2i(
			safe_area.position.x - window_position.x,
			safe_area.position.y - window_position.y
		)

		top_margin = max(0, relative_position.y)
	else:
		var inset_top = 40
		top_margin = inset_top

	add_theme_constant_override("margin_top", top_margin)
