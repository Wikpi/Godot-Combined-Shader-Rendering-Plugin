tool
extends EditorPlugin

class TrackedNode:
	var node: Node2D
	var parent_node: Node
	var plugin_node: Node2D
	var material: Material

	func _init(new_node: Node2D, new_parent_node: Node, new_plugin_node: Node2D) -> void:
		node = new_node
		parent_node = new_parent_node
		plugin_node = new_plugin_node

# Reference to the root plugin script.
var plugin_script: EditorPlugin
# Reference to the custom plugin node object.
var plugin_node: PackedScene = preload("res://addons/composite-shading/CompositeShadingSprite.tscn")
# A dictionary containing all nodes which currently have the plugin enabled.
# Key -> Value = (original node) -> (TrackedNode class object).
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

# `check_tracking` validates currently tracked nodes 
# and removes leftovers for any invalid nodes.
func check_tracking() -> void:
	for node in tracked_nodes:
		if is_instance_valid(node) && node.is_inside_tree():
			continue
		remove_tracking(node)

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
	
	var new_tracked_node: TrackedNode = TrackedNode.new(new_node, new_node.get_parent(), new_plugin_node)
	
	tracked_nodes[new_node] = new_tracked_node

# `remove_tracking` fully removes any plugin effect on the specified node.
func remove_tracking(new_node: Node2D) -> void:
	if !tracked_nodes.has(new_node):
		return
	
	plugin_script.plugin_clean.cleanup_tracked_node(new_node)
	
	# Erase dictionary entry at the end to allow for dictionary value grabbing beforehand.
	tracked_nodes.erase(new_node)

# `update_node_material` updates the tracked node plugin used material.
func update_node_material(new_material: Material, new_node: Node2D) -> void:
	if !tracked_nodes.has(new_node):
		return

	tracked_nodes[new_node].plugin_node.modify_sprite_material(new_material)

# `get_meta_data` retreives nodes existing meta data field value. 
func get_meta_data(new_node: Node2D, field: String, fallback):
	if !new_node.has_meta(plugin_script.plugin_tools.tracked_node_meta):
		return fallback
	
	var meta: Dictionary = new_node.get_meta(plugin_script.plugin_tools.tracked_node_meta, null)
	if !meta:
		return fallback
	
	if !meta.has(field):
		return fallback
	
	return meta.get(field)

# `set_meta_data` updates nodes meta data field.
func set_meta_data(new_node: Node2D, field: String, value) -> void:
	var meta: Dictionary = {}
	if new_node.has_meta(plugin_script.plugin_tools.tracked_node_meta):
		meta = new_node.get_meta(plugin_script.plugin_tools.tracked_node_meta, null)
	
	meta[field] = value
	
	new_node.set_meta(plugin_script.plugin_tools.tracked_node_meta, meta)

# -------------------------------------------------------------
# ================= Helper Methods ============================
# -------------------------------------------------------------

# `restore_node_tracking` restores all curent scene root nodes which had the plugin enabled.
func restore_node_tracking(root: Node):
	# Have to check node meta data to determine if it has the plugin enabled
	if root.has_meta(plugin_script.plugin_tools.tracked_node_meta):
		var meta = root.get_meta(plugin_script.plugin_tools.tracked_node_meta)
		if meta:
			if get_meta_data(root, "tracked", false):
				add_tracking(root)
			
			var material: Material = get_meta_data(root, "material", null)
			if material:
				update_node_material(material, root)

	# Recursively check all children
	for child in root.get_children():
		restore_node_tracking(child)

# `get_tracked_nodes` returns the current tracked node list.
func get_tracked_nodes() -> Dictionary:
	return plugin_script.plugin_track.tracked_nodes
