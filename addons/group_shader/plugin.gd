tool
extends EditorPlugin

var plugin_ui_reference = preload("res://addons/group_shader/plugin_ui.gd")
var plugin_ui

var plugin_track_reference = preload("res://addons/group_shader/plugin_track.gd")
var plugin_track

var plugin_clean_reference = preload("res://addons/group_shader/plugin_clean.gd")
var plugin_clean

# Plugin activation
func _enter_tree() -> void:
	initialize_plugin()
	
	add_inspector_plugin(plugin_ui)
	
	get_tree().connect("idle_frame", self, "process_plugin")

# Plugin deactivation
func _exit_tree() -> void:
	remove_inspector_plugin(plugin_ui)
	
	plugin_clean.cleanup()

# On manual plugin disable remove any leftover traces of the plugin. 
func disable_plugin() -> void:
	plugin_clean.cleanup_meta()

func process_plugin() -> void:
	plugin_track.restore_tracking()

func initialize_plugin() -> void:
	plugin_ui = plugin_ui_reference.new()
	plugin_ui.plugin_script = self
	
	plugin_track = plugin_track_reference.new()
	plugin_track.plugin_script = self
	
	plugin_clean = plugin_clean_reference.new()
	plugin_clean.plugin_script = self
