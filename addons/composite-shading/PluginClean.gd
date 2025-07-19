tool
extends Node2D

# Reference to the root plugin manager.
var manager: Node2D
# Dictionary containing nodes which currently have the plugin enabled.
# Only derived from the PluginTrack.gd script as a reference.
# Key -> Value = (original node) -> (TrackedNode class object).
var tracked_nodes: Dictionary setget , update_tracked_node_list

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

# `cleanup` performs a full plugin deep clean.
func cleanup() -> void:
	for node in self.tracked_nodes:
		cleanup_tracked_node(node)

# `cleanup_meta` fully cleans any leftover meta data attached to the tracked nodes.
func cleanup_meta() -> void:
	for node in self.tracked_nodes:
		cleanup_node_meta(node)

# -------------------------------------------------------------
# ================= Helper Methods ============================
# -------------------------------------------------------------

# `cleanup_tracked_node` fully cleans any leftovers of a particular node.
# This does not include meta data as that is reserved only for manual plugin deactivation.
func cleanup_tracked_node(new_node: Node2D) -> void:
	if !is_instance_valid(new_node):
		return
		
	# Clean the nodes respective custom plugin node
	cleanup_plugin_node(new_node)

	cleanup_tracked_node_leftovers(new_node)

# `cleanup_tracked_node_leftovers` removes any residual plugin nodes related to the specified ndoe. 
func cleanup_tracked_node_leftovers(new_node: Node2D) -> void:
	# All plugin custom nodes are stored as siblings of the original node
	# Therefore the parent of the original node will have all the info
	var node_parent: Node = self.tracked_nodes[new_node].parent_node
	
	# Clean up ay residual accidental plugin custom nodes
	for child in node_parent.get_children():
		# Custom plugin node name follow the pattern: [node_name]MergedSprite
		# But could potentially have many instances
		if !child.name.begins_with("%s%s" % [new_node.name, CompositeShadingTools.plugin_node_suffix]):
			continue
		child.queue_free()

# `cleanup_plugin_node` removes leftover custom plugin node for a respective root node.
func cleanup_plugin_node(new_node: Node2D) -> void:
	var plugin_node: Node2D = self.tracked_nodes[new_node].plugin_node
	
	if !is_instance_valid(plugin_node):
		return
	plugin_node.queue_free()

# `cleanup_node_meta` removes meta data from a particular node.
func cleanup_node_meta(new_node: Node2D) -> void:
	new_node.set_meta(CompositeShadingTools.tracked_node_meta, null)

# `update_tracked_node_list` dynamically updates the local trackedd node list.
# `tracked_nodes` getter function.
func update_tracked_node_list() -> Dictionary:
	if manager:
		tracked_nodes = manager.get_tracked_nodes()
	return tracked_nodes
