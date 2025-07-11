tool
extends EditorInspectorPlugin

# Reference to the root plugin script.
var plugin_script: EditorPlugin

# The size of the plugin UI header.
var header_min_size: Vector2 = Vector2(0, 23)
# The background color of the plugin UI header.
var header_bg_color: Color = Color(0.235, 0.247, 0.267)
# The text of the plugin UI header.
var header_text: String = "Composite Shader Rendering"
# The text color for the plugin UI header.
var header_text_color: Color = Color(0.733, 0.737, 0.749)

# The text of the plugin UI checkbox.
var text_label_text: String = "Composite Shading"
# The color of the plugin UI checkbox text.
var text_label_color: Color = Color(0.553, 0.557, 0.561)
# The tooltip of the plugin UI checkbox text.
var text_label_tooltip: String = """
	When enabled, this plugin gathers all visible Sprite nodes under this Node2D,
	renders them into an off‑screen Viewport, and displays the result as a single composite Sprite.
	Any CanvasItem material or shader you assign here will automatically be applied to the entire group
	and will update in real time as child sprites move, change, or toggle visibility.
"""

# The size of the plugin checkbox.
var checkbox_min_size: Vector2 = Vector2(0, 23)
# The background color of the plugin UI checkbox.
var checkbox_bg_color: Color = Color(0.11, 0.122, 0.137)
# The text color of the plugin UI checkbox.
var checkbox_label_color: Color = Color(0.667, 0.671, 0.682)

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

# Determines which objects have access to the plugin inspector UI.
func can_handle(object) -> bool:
	return object is Node2D

# Displays the plugin inspector UI.
func parse_begin(object) -> void:
	# Plugin UI header container
	var header: Control = make_header()

	add_custom_control(header)

	# Plugin UI checkbox container
	var checkbox: HBoxContainer = make_checkbox(object)

	add_custom_control(checkbox)

# -------------------------------------------------------------
# ================= Helper Methods ============================
# -------------------------------------------------------------

# `make_header` creates a new plugin UI header container.
func make_header():
	# Stores the full header: background and header
	var header_container = create_control(header_min_size)
	
	# Header colored background object
	var bg = create_color_rect(header_bg_color)
	header_container.add_child(bg)
	
	# Sores centered header text and icon
	var hbox: HBoxContainer = create_hbox()
	hbox.anchor_right  = 1
	hbox.anchor_bottom = 1
	hbox.alignment = BoxContainer.ALIGN_CENTER

	# Header icon object
	var icon = TextureRect.new()
	if plugin_script:
		icon.texture = load(plugin_script.plugin_tools.plugin_icon_path)
	
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	hbox.add_child(icon)
	
	# Header text object
	var header: Label = create_label(header_text, header_text_color)
	header.size_flags_horizontal = Control.SIZE_FILL # Remove default expand flag
	hbox.add_child(header)
	
	header_container.add_child(hbox)
	
	return header_container

# `make_checkbox` creatse a new plugin UI checkbox container.
func make_checkbox(object: Node2D) -> HBoxContainer:
	# The final overall checkbox container
	var checkbox_container: HBoxContainer = create_hbox()

	# Checkbox text label object
	var text_label: Label = create_label(text_label_text, text_label_color)
	text_label.hint_tooltip = text_label_tooltip # Tooltip on text hover
	text_label.mouse_filter = Control.MOUSE_FILTER_PASS
	checkbox_container.add_child(text_label)
	
	# Container which will hold the background and the full checkbox button
	var container: Control = create_control(checkbox_min_size)
	
	# Checkbox button background
	var bg: ColorRect = create_color_rect(checkbox_bg_color)
	container.add_child(bg)
	
	# Container to store the full checkbox button
	var checkbox_button: HBoxContainer = create_hbox()

	# Checkbox button object
	var checkbox: CheckBox = CheckBox.new()
	checkbox.focus_mode = Control.FOCUS_NONE
	checkbox.pressed = object.get_meta(plugin_script.plugin_tools.tracked_node_meta, false)
	checkbox.align = Label.ALIGN_LEFT
	checkbox_button.add_child(checkbox)

	# Checkbox button text label object
	var on_label: Label = create_label("On", checkbox_label_color)
	checkbox_button.add_child(on_label)
	
	# Methods to handle checkbox `toggle` signal
	checkbox.connect("toggled", self, "handle_new_node_tracking", [object])
	checkbox.connect("toggled", self, "handle_on_label", [on_label])
	
	# Update checkbox label on initial load
	handle_on_label(checkbox.pressed, on_label)

	container.add_child(checkbox_button)

	checkbox_container.add_child(container)

	return checkbox_container

# `create_control` makes a new default Control with the provided size.
func create_control(size: Vector2) -> Control:
	var new_control: Control = Control.new()
	
	new_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_control.size_flags_vertical = Control.SIZE_FILL
	
	new_control.rect_min_size = size

	return new_control

# `create_color_rect` makes a new default ColorRect with the provided color value.
func create_color_rect(color: Color) -> ColorRect:
	var new_color_rect: ColorRect = ColorRect.new()
	
	new_color_rect.color = color
	new_color_rect.anchor_right  = 1
	new_color_rect.anchor_bottom = 1
	new_color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_color_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	return new_color_rect

# `create_label` makes a new default label with provided text and color.
func create_label(text: String, color: Color = Color(1, 1, 1)) -> Label:
	var new_label: Label = Label.new()
	
	new_label.text = text
	new_label.add_color_override("font_color", color)
	new_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_label.align = Label.ALIGN_LEFT

	return new_label

# `create_hbox` makes a new default HBoxContainer. 
func create_hbox() -> HBoxContainer:
	var new_hbox: HBoxContainer = HBoxContainer.new()
	new_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	return new_hbox

# `handle_new_node_tracking` enables or disables the plugin effect on a new specified node.
# This method is `checkbox` `toggled` signal handler.
func handle_new_node_tracking(status: bool, node: Node2D) -> void:
	# Sets according meta data for the node
	node.set_meta(plugin_script.plugin_tools.tracked_node_meta, status)

	# Add or remove the node from tracked list
	if status:
		plugin_script.plugin_track.add_tracking(node)
	else:
		plugin_script.plugin_track.remove_tracking(node)

# `handle_on_label` sets the respective color for the checkbox "on" label text.
# This method is `checkbox` `toggled` signal handler.
func handle_on_label(status: bool, label: Label) -> void:
	if status:
		#on_label.add_color_override("font_color", Color(0.36, 0.69, 1))
		label.add_color_override("font_color", Color(0.988, 0.42, 0.847))
	else:
		label.add_color_override("font_color", Color(0.553, 0.557, 0.561))
