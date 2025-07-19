tool
extends EditorPlugin

# Reference to the plugin UI script.
var plugin_ui_reference: GDScript = preload("res://addons/composite-shading/PluginUI.gd")
# Current plugin UI script instance.
var plugin_ui: EditorInspectorPlugin

var plugin_manager_reference: PackedScene = preload("res://addons/composite-shading/CompositeShadingManager.tscn")
var plugin_manager: Node2D

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

# Plugin activation.
func _enter_tree() -> void:
	# Add plugin UI
	plugin_ui = plugin_ui_reference.new()
	add_inspector_plugin(plugin_ui)
	
	get_tree().connect("node_added", self, "initialise_plugin_manager")
	initialise_plugin_manager(get_editor_interface().get_edited_scene_root())
	
# Plugin deactivation.
func _exit_tree() -> void:
	# Remove plugin UI
	remove_inspector_plugin(plugin_ui)
	
	if !plugin_manager:
		return
	
	plugin_manager.call("handle_exit")
	
	plugin_manager.queue_free()

# Manual plugin deactivation.
func disable_plugin() -> void:
	if !plugin_manager:
		return
	plugin_manager.call("handle_disable")

# -------------------------------------------------------------
# =================== Helper Methods ==========================
# -------------------------------------------------------------

func initialise_plugin_manager(new_node: Node) -> void:
	if new_node != get_editor_interface().get_edited_scene_root():
		return
	
	if plugin_manager:
		plugin_manager.queue_free()

	var new_plugin_manager: Node2D = plugin_manager_reference.instance()
	new_plugin_manager.owner = new_node
	new_node.add_child(new_plugin_manager)
	
	plugin_ui.manager = new_plugin_manager
	
	plugin_manager = new_plugin_manager
