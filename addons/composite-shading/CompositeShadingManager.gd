extends Node2D

#tool
class_name CompositeShadingManager

# Reference to the plugin tracking script.
var plugin_track_reference: GDScript = preload("res://addons/composite-shading/PluginTrack.gd")
# Current plugin tracking script instance.
var plugin_track: Node2D

# Reference to the plugin cleaning script.
var plugin_clean_reference: GDScript = preload("res://addons/composite-shading/PluginClean.gd")
# Current plugin cleaning script instance.
var plugin_clean: Node2D

# Reference to the static helper plugin tools.
var plugin_tools: GDScript = preload("res://addons/composite-shading/PluginTools.gd")

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

func _enter_tree() -> void:
	plugin_track = plugin_track_reference.new()
	plugin_track.manager = self # Pass self reference
	
	plugin_clean = plugin_clean_reference.new()
	plugin_clean.manager = self # Pass self reference
	print("need to add back")
	# Check if plugin tracked nodes need to be restored
	plugin_track.restore_node_tracking(get_parent())
	
	set_process(true)
	
func _process(_delta) -> void:
#	if !plugin_track:
#		return
	# Check if custom plugin nodes need to be cleanedup
#	plugin_track.check_tracking()
	if !Engine.is_editor_hint():
		plugin_track.restore_node_tracking(get_parent())
		print("runtime")

func handle_exit() -> void:
	if !plugin_clean:
		return
	plugin_clean.cleanup()

func handle_disable() -> void:
	if !plugin_clean:
		return
	plugin_clean.cleanup_meta()

func add_tracking(new_node: Node2D) -> void:
	if !plugin_track:
		return
	plugin_track.add_tracked_node(new_node)

func remove_tracking(new_node: Node2D) -> void:
	if !plugin_track:
		return
	plugin_track.remove_tracked_node(new_node)

func cleanup_tracking(new_node: Node2D) -> void:
	if !plugin_clean:
		return
	plugin_clean.cleanup_tracked_node(new_node)

# `get_tracked_nodes` returns the current tracked node list.
func get_tracked_nodes() -> Dictionary:
	if !plugin_track:
		return {}
	return plugin_track.tracked_nodes

# -------------------------------------------------------------
# =================== Helper Methods ==========================
# -------------------------------------------------------------
