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

var plugin_node_reference = preload("res://addons/group_shader/PluginMergedSprite.tscn")
var plugin_node_list: Dictionary = {}

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
		cleanup_tracked_node(node)

func process_groups() -> void:
	if len(tracked_nodes) <= 0:
		return
	
	for node in tracked_nodes:
		if !is_instance_valid(node):
			continue
	
		if !plugin_node_list.has(node):
			continue
			
		var plugin_node = plugin_node_list[node]

		var sprites = plugin_tools.get_sprites(node)
		var signature = plugin_tools.generate_node_signature(sprites)

		if merged_data.has(node) && merged_data[node] == signature:
			continue
		
		var bounds = plugin_tools.calculate_sprite_bounds(sprites)
		
		plugin_node.modify_sprite_material(node.material.duplicate())
		
		plugin_node.merge_sprites(sprites, bounds)
		
		merged_data[node] = signature

# `add_tracking` starts tracking a new node, which needs a merged sprite.
func add_tracking(node) -> void:
	tracked_nodes.append(node)
	
	# For each new tracked node create a seperate plugin node, which will display
	# the merged sprite. Each plugin node will have a reference to the node it is
	# merging in its name.
	var new_plugin_node = plugin_node_reference.instance()
	new_plugin_node.name = "%sMergedSprite" % node.name
	
	# Add the new node so that the merged sprite and the original sprite
	# can be siblings with the merged sprite being on top.
	node.get_parent().add_child(new_plugin_node)
	
	plugin_node_list[node] = new_plugin_node

func remove_tracking(node) -> void:
	cleanup_tracked_node(node)

func cleanup_tracked_node(node) -> void:
	tracked_nodes.erase(node)
	merged_data.erase(node)
	
	cleanup_plugin_node(node)

func cleanup_plugin_node(node) -> void:
	var plugin_node = plugin_node_list[node]
	
	plugin_node_list.erase(plugin_node.name)
	
	plugin_node.queue_free()
