tool
extends EditorInspectorPlugin

var plugin

var inspected_nodes := {}

func can_handle(object):
	return object is Node2D

func parse_begin(object):
	if inspected_nodes.has(object):
		return
	inspected_nodes[object] = true
	
	var header = make_header()

	add_custom_control(header)

	var checkbox = make_checkbox(object)

	add_custom_control(checkbox)

func parse_end():
	inspected_nodes.clear()

func make_header() -> Control:
		# 1) Parent container that forces a height
	var container = Control.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical   = Control.SIZE_FILL
	container.rect_min_size = Vector2(0, 23)

	# 2) Background ColorRect
	var bg = ColorRect.new()
	bg.color = Color(0.235, 0.247, 0.267)
	# manually pin it to fill the container:
	bg.anchor_left   = 0
	bg.anchor_top    = 0
	bg.anchor_right  = 1
	bg.anchor_bottom = 1
	bg.margin_left   = 0
	bg.margin_top    = 0
	bg.margin_right  = 0
	bg.margin_bottom = 0
	container.add_child(bg)

	# 3) Header Label
	var header = Label.new()
	header.text  = "Sprite Merger"
	header.align  = Label.ALIGN_CENTER
	header.valign = Label.VALIGN_CENTER
	# pin it the same way:
	header.anchor_left   = 0
	header.anchor_top    = 0
	header.anchor_right  = 1
	header.anchor_bottom = 1
	header.margin_left   = 0
	header.margin_top    = 0
	header.margin_right  = 0
	header.margin_bottom = 0
	container.add_child(header)
	
	return container
	
func make_checkbox(object) -> HBoxContainer:
	# ── ROW (Text + Checkbox + ON) ───────────────────────────
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# --- Label (with tooltip when hovering)
	var lbl = Label.new()
	lbl.text = "Enable Sprite Merge"
	lbl.add_color_override("font_color", Color(0.553, 0.557, 0.561))
	lbl.hint_tooltip = "When checked, this Node2D will bake all child sprites into one composite for shader processing."
	lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.align = Label.ALIGN_LEFT
	row.add_child(lbl)

	var checkbox = HBoxContainer.new()
	checkbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# --- Checkbox
	var cb = CheckBox.new()
	cb.focus_mode = Control.FOCUS_NONE

	cb.pressed = object.get_meta("merge_enabled", false)
	cb.align = Label.ALIGN_LEFT
	
	cb.connect("toggled", self, "handle_checkbox_toggle", [object])
	
	checkbox.add_child(cb)

	# --- ON label
	var on_label = Label.new()
	on_label.text = "On"
	on_label.align = Label.ALIGN_LEFT
	
	checkbox.add_child(on_label)

	cb.connect("toggled", self, "_update_on_label", [on_label])

	_update_on_label(cb.pressed, on_label)

	row.add_child(checkbox)

	return row

func handle_checkbox_toggle(status: bool, node):
	node.set_meta("merge_enabled", status)

	if status:
		plugin.add_tracking(node)
	else:
		plugin.remove_tracking(node)

func _update_on_label(pressed: bool, on_label: Label) -> void:
	# Fake inspector accent color: light blue
	if pressed:
#		on_label.add_color_override("font_color", Color(0.36, 0.69, 1)) # Approximate accent color
		on_label.add_color_override("font_color", Color(0.988, 0.42, 0.847)) # Approximate accent color
	else:
		on_label.add_color_override("font_color", Color(0.553, 0.557, 0.561)) # Muted gray
