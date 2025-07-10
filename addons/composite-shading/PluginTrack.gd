tool
extends EditorPlugin

# Reference to the root plugin script.
var plugin_script: EditorPlugin
# Reference to the custom plugin node object.
var plugin_node: PackedScene = preload("res://addons/composite-shading/PluginMergedSprite.tscn")
# A dictionary containing all nodes which currently have the plugin enabled.
# Key -> Value = (original node) -> (plugin node representation).
var tracked_nodes: Dictionary = {}
# Reference to the current scene root.
var current_root: Node

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

# `restore_tracking` restores any lost tracked nodes.
func restore_tracking() -> void:
	# Current scene root
	var new_root: Node = get_editor_interface().get_edited_scene_root()
	if !new_root || new_root == current_root:
		return
	# Only rescan for a new scene root
	current_root = new_root
	
	restore_node_tracking(current_root)

# `add_tracking` starts tracking a new node, which needs a merged sprite.
func add_tracking(new_node: Node2D) -> void:
	if tracked_nodes.has(new_node):
		return
	
	# For each new tracked node create a seperate plugin node, which will display
	# the merged sprite. Each plugin node will have a reference to the node it is
	# merging in its name.
	var new_plugin_node = plugin_node.instance()
	new_plugin_node.name = "%s%s" % [new_node.name, plugin_script.plugin_tools.plugin_node_suffix]
	new_plugin_node.root_node = new_node
	
	# Add the new node so that the merged sprite and the original sprite
	# can be siblings with the merged sprite being on top.
	new_node.get_parent().add_child(new_plugin_node)
	
	tracked_nodes[new_node] = new_plugin_node

# `remove_tracking` fully removes any plugin effect on the specified node.
func remove_tracking(new_node: Node2D) -> void:
	plugin_script.plugin_clean.cleanup_tracked_node(new_node)
	
	# Erase dictionary entry at the end to allow for dictionary value grabbing beforehand.
	tracked_nodes.erase(new_node)

# -------------------------------------------------------------
# ================= Helper Methods ============================
# -------------------------------------------------------------

# `restore_node_tracking` restores all curent scene root nodes which had the plugin enabled.
func restore_node_tracking(root: Node):
	var meta_data: String = plugin_script.plugin_tools.tracked_node_meta
	
	# Have to check node meta data to determine if it has teh plugin enabled
	if root.has_meta(meta_data) and root.get_meta(meta_data):
		add_tracking(root)

	# Recursively check all children
	for child in root.get_children():
		restore_node_tracking(child)

# `get_tracked_nodes` returns the current tracked node list.
func get_tracked_nodes() -> Dictionary:
	return plugin_script.plugin_track.tracked_nodes
