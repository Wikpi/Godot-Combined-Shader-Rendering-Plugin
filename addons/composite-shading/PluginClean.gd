tool
extends EditorPlugin

# Reference to the root plugin script.
var plugin_script: EditorPlugin
# Dictionary containing nodes which currently have the plugin enabled.
# Only derived from the PluginTrack.gd script as a reference.
# Key -> Value = (original node) -> (plugin node representation).
var tracked_nodes: Dictionary

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

# `cleanup` performs a full plugin deep clean.
func cleanup() -> void:
	# Update tracked nodes
	if plugin_script:
		tracked_nodes = plugin_script.plugin_track.get_tracked_nodes()
	
	for node in tracked_nodes:
		cleanup_tracked_node(node)

# `cleanup_meta` fully cleans any leftover meta data attached to the tracked nodes.
func cleanup_meta() -> void:
	# Update tracked nodes
	if plugin_script:
		tracked_nodes = plugin_script.plugin_track.get_tracked_nodes()
	
	for node in tracked_nodes:
		cleanup_node_meta(node)

# -------------------------------------------------------------
# ================= Helper Methods ============================
# -------------------------------------------------------------

# `cleanup_tracked_node` fully cleans any leftovers of a particular node.
# This does not include meta data as that is reserved only for manual plugin deactivation.
func cleanup_tracked_node(new_node: Node2D) -> void:
	if !is_instance_valid(new_node):
		return
	
	if tracked_nodes.has(new_node):
		# Clean the nodes respective custom plugin node
		cleanup_plugin_node(tracked_nodes[new_node])
	
	# All plugin custom nodes are stored as siblings of the original node
	# Therefore the parent of the original node will have all the info
	var node_parent = new_node.get_parent()
	
	# Clean up ay residual accidental plugin custom nodes
	for child in node_parent.get_children():
		# Custom plugin node name follow the pattern: [node_name]MergedSprite
		# But could potentially have many instances
		if !child.name.begins_with("%s%s" % [new_node.name, plugin_script.plugin_tools.plugin_node_suffix]):
			continue
		child.queue_free()

# `cleanup_plugin_node` removes leftover custom plugin node for a respective root node.
func cleanup_plugin_node(new_plugin_node: Node2D) -> void:
	if !is_instance_valid(new_plugin_node):
		return
	new_plugin_node.queue_free()

# `cleanup_node_meta` removes meta data from a particular node.
func cleanup_node_meta(new_node: Node2D) -> void:
	new_node.set_meta(plugin_script.plugin_tools.tracked_node_meta, null)


