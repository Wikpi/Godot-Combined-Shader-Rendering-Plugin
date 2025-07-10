tool
extends EditorPlugin

var plugin_script

var plugin_node = preload("res://addons/group_shader/PluginMergedSprite.tscn")

var tracked_nodes: Dictionary = {}

var current_root

func restore_tracking() -> void:
	var new_root = get_editor_interface().get_edited_scene_root()
	if !new_root || new_root == current_root:
		return

	current_root = new_root
	
	restore_node_tracking(current_root)

func restore_node_tracking(root):
	if !(root is Node2D):
		return
	
	if root.has_meta("merge_enabled") and root.get_meta("merge_enabled"):
		add_tracking(root)

	for child in root.get_children():
		restore_node_tracking(child)

# `add_tracking` starts tracking a new node, which needs a merged sprite.
func add_tracking(node) -> void:
	# For each new tracked node create a seperate plugin node, which will display
	# the merged sprite. Each plugin node will have a reference to the node it is
	# merging in its name.
	var new_plugin_node = plugin_node.instance()
	new_plugin_node.name = "%sMergedSprite" % node.name
	new_plugin_node.root_node = node
	
	# Add the new node so that the merged sprite and the original sprite
	# can be siblings with the merged sprite being on top.
	node.get_parent().add_child(new_plugin_node)
	
	tracked_nodes[node] = new_plugin_node

func remove_tracking(node) -> void:
	plugin_script.plugin_clean.cleanup_tracked_node(node)

	tracked_nodes.erase(node)

func get_tracked_nodes() -> Dictionary:
	return plugin_script.plugin_track.tracked_nodes
