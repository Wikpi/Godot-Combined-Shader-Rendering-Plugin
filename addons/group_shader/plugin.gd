tool
extends EditorPlugin

var checkbox: CheckBox
var checkbox_status: bool

var viewport: Viewport
var sprite: Sprite

var shader

var plugin_location: int = CONTAINER_PROPERTY_EDITOR_BOTTOM

var plugin_tools = preload("res://addons/group_shader/plugin_tools.gd")

var plugin_ui_preload = preload("res://addons/group_shader/plugin_ui.gd")
var plugin_ui

var tracked_nodes: Array = []
var merged_data: Dictionary = {} # Cache merged state

# Plugin activation
func _enter_tree() -> void:
	if plugin_ui:
		return
	
	plugin_ui = plugin_ui_preload.new()
	plugin_ui.plugin = self
	
	add_inspector_plugin(plugin_ui)
	
	get_tree().connect("idle_frame", self, "process_groups")

# Plugin deactivation
func _exit_tree() -> void:
	if plugin_ui:
		remove_inspector_plugin(plugin_ui)
		plugin_ui = null
	
	for node in tracked_nodes:
		plugin_tools.cleanup_node(node)
		
		merged_data.erase(node)
		tracked_nodes.clear()

func process_groups() -> void:
	if len(tracked_nodes) <= 0:
		return
	
	for node in tracked_nodes:
		if !is_instance_valid(node):
			continue

		var sprites = plugin_tools.get_sprites(node)
		var signature = plugin_tools.generate_node_signature(sprites)

		if merged_data.has(node) && merged_data[node] == signature:
			continue # No change

		plugin_tools.cleanup_node(node)
		
		merged_data.erase(node)
		
		var result_sprite = plugin_tools.merge_sprites(node, sprites)
		
		merged_data[node] = signature
	
func add_tracking(node) -> void:
	tracked_nodes.append(node)

func remove_tracking(node) -> void:
	tracked_nodes.erase(node)
	
	plugin_tools.cleanup_node(node)

	merged_data.erase(node)
