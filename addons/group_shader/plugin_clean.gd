tool
extends EditorPlugin

var plugin_script

var tracked_nodes

func cleanup() -> void:
	tracked_nodes = plugin_script.plugin_track.get_tracked_nodes()
	
	for node in tracked_nodes:
		cleanup_tracked_node(node)

func cleanup_tracked_node(node) -> void:
	cleanup_plugin_node(tracked_nodes[node])

	for child in node.get_parent().get_children():
		if !child.name.begins_with("%sMergedSprite" % node.name):
			continue
		child.queue_free()

func cleanup_plugin_node(new_plugin_node) -> void:
	if !is_instance_valid(new_plugin_node):
		return
	new_plugin_node.queue_free()

func cleanup_meta() -> void:
	tracked_nodes = plugin_script.plugin_track.get_tracked_nodes()
	
	for node in tracked_nodes:
		cleanup_node_meta(node)

func cleanup_node_meta(new_node) -> void:
	new_node.set_meta("merge_enabled", null)


