tool
extends EditorPlugin

# Reference to the plugin UI script.
var plugin_ui_reference: GDScript = preload("res://addons/composite-shading/PluginUI.gd")
# Current plugin UI script instance.
var plugin_ui: EditorInspectorPlugin

# Reference to the plugin tracking script.
var plugin_track_reference: GDScript = preload("res://addons/composite-shading/PluginTrack.gd")
# Current plugin tracking script instance.
var plugin_track: EditorPlugin

# Reference to the plugin cleaning script.
var plugin_clean_reference: GDScript = preload("res://addons/composite-shading/PluginClean.gd")
# Current plugin cleaning script instance.
var plugin_clean: EditorPlugin

# Reference to the static helper plugin tools.
var plugin_tools: GDScript = preload("res://addons/composite-shading/PluginTools.gd")

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

# Plugin activation.
func _enter_tree() -> void:
	# Instantiate plugin scripts
	initialize_plugin()
	
	# Add plugin UI
	add_inspector_plugin(plugin_ui)
	
	# Add idle timer processing
	get_tree().connect("idle_frame", self, "process_plugin")

# Plugin deactivation.
func _exit_tree() -> void:
	# Remove plugin UI
	remove_inspector_plugin(plugin_ui)
	
	# Remove the idle timer processing
	get_tree().disconnect("idle_frame", self, "process_plugin")
	
	# Full plugin clean
	plugin_clean.cleanup()

# Manual plugin deactivation.
func disable_plugin() -> void:
	# Only on manual plugin disable remove any leftover traces of the plugin. 
	plugin_clean.cleanup_meta()

# -------------------------------------------------------------
# ================= Helper Methods ============================
# -------------------------------------------------------------

# `process_plugin` acts as a process method for the plugin.
func process_plugin() -> void:
	# Check if plugin tracked nodes need to be restored
	plugin_track.restore_tracking()
	# Check if custom plugin nodes need to be cleanedup
	plugin_track.check_tracking()

# `initialize_plugin` establishes plugin state on startup.
func initialize_plugin() -> void:
	plugin_ui = plugin_ui_reference.new()
	plugin_ui.plugin_script = self # Pass self reference
	
	plugin_track = plugin_track_reference.new()
	plugin_track.plugin_script = self # Pass self reference
	
	plugin_clean = plugin_clean_reference.new()
	plugin_clean.plugin_script = self # Pass self reference
