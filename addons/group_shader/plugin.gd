tool
extends EditorPlugin

var plugin_ui_reference = preload("res://addons/group_shader/plugin_ui.gd")
var plugin_ui

var tracked_nodes: Dictionary = {}

var plugin_node_reference = preload("res://addons/group_shader/PluginMergedSprite.tscn")

var current_root

# Plugin activation
func _enter_tree() -> void:
	plugin_ui = plugin_ui_reference.new()
	plugin_ui.plugin = self
	
	add_inspector_plugin(plugin_ui)
	
	get_tree().connect("idle_frame", self, "process_plugin")

# Plugin deactivation
func _exit_tree() -> void:
	remove_inspector_plugin(plugin_ui)
	
	for node in tracked_nodes:
		cleanup_tracked_node(node)

# On manual plugin disable remove any leftover traces of the plugin. 
func disable_plugin():
	for node in tracked_nodes.keys():
		node.set_meta("merge_enabled", null)

func process_plugin():
	var new_root = get_editor_interface().get_edited_scene_root()
	if !new_root || new_root == current_root:
		return

	current_root = new_root
	
	restore_tracking(current_root)

func restore_tracking(root):
	if !(root is Node2D):
		return
	
	if root.has_meta("merge_enabled") and root.get_meta("merge_enabled"):
		add_tracking(root)

	for child in root.get_children():
		restore_tracking(child)

# `add_tracking` starts tracking a new node, which needs a merged sprite.
func add_tracking(node) -> void:
	# For each new tracked node create a seperate plugin node, which will display
	# the merged sprite. Each plugin node will have a reference to the node it is
	# merging in its name.
	var new_plugin_node = plugin_node_reference.instance()
	new_plugin_node.name = "%sMergedSprite" % node.name
	new_plugin_node.root_node = node
	
	# Add the new node so that the merged sprite and the original sprite
	# can be siblings with the merged sprite being on top.
	node.get_parent().add_child(new_plugin_node)
	
	tracked_nodes[node] = new_plugin_node

func remove_tracking(node) -> void:
	cleanup_tracked_node(node)

func cleanup_tracked_node(node) -> void:
	cleanup_plugin_node(node)

	for child in node.get_parent().get_children():
		if !child.name.begins_with("%sMergedSprite" % node.name):
			continue
		child.queue_free()
		
	tracked_nodes.erase(node)

func cleanup_plugin_node(node) -> void:
	var plugin_node = tracked_nodes[node]
	
	if !is_instance_valid(plugin_node):
		return
	plugin_node.queue_free()
