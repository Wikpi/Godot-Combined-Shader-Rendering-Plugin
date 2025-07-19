tool
extends Node2D

class TrackedNode:
	var node: Node2D
	var parent_node: Node
	var plugin_node: Node2D

	func _init(new_node: Node2D, new_parent_node: Node, new_plugin_node: Node2D) -> void:
		node = new_node
		parent_node = new_parent_node
		plugin_node = new_plugin_node

# Reference to the root plugin manager.
var manager: Node2D
# Reference to the custom plugin node object.
var plugin_node: PackedScene = preload("res://addons/composite-shading/CompositeShadingSprite.tscn")
# A dictionary containing all nodes which currently have the plugin enabled.
# Key -> Value = (original node) -> (TrackedNode class object).
var tracked_nodes: Dictionary = {}

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

# `restore_node_tracking` restores all curent scene root nodes which had the plugin enabled.
func restore_node_tracking(root: Node) -> void:
	# Have to check node meta data to determine if it has the plugin enabled
	if root.has_meta(CompositeShadingTools.tracked_node_meta):
		var meta = root.get_meta(CompositeShadingTools.tracked_node_meta)
		if meta &&  CompositeShadingTools.get_meta_data(root, "tracked", false):
			print("added back ", root)
			add_tracked_node(root)

	# Recursively check all children
	for child in root.get_children():
		restore_node_tracking(child)

# `check_tracking` validates currently tracked nodes 
# and removes leftovers for any invalid nodes.
func check_tracking() -> void:
	for node in tracked_nodes:
		if is_instance_valid(node) && node.is_inside_tree():
			continue
		remove_tracked_node(node)

# `add_tracking` starts tracking a new node, which needs a merged sprite.
func add_tracked_node(new_node: Node2D) -> void:
	if tracked_nodes.has(new_node):
		return
	
	# For each new tracked node create a seperate plugin node, which will display
	# the merged sprite. Each plugin node will have a reference to the node it is
	# merging in its name.
	var new_plugin_node = plugin_node.instance()
	new_plugin_node.name = "%s%s" % [new_node.name, CompositeShadingTools.plugin_node_suffix]
	new_plugin_node.root_node = new_node
	
	# Add the new node so that the merged sprite and the original sprite
	# can be siblings with the merged sprite being on top.
	new_node.get_parent().add_child(new_plugin_node)
	
	var new_tracked_node: TrackedNode = TrackedNode.new(new_node, new_node.get_parent(), new_plugin_node)
	
	tracked_nodes[new_node] = new_tracked_node

# `remove_tracking` fully removes any plugin effect on the specified node.
func remove_tracked_node(new_node: Node2D) -> void:
	if !tracked_nodes.has(new_node):
		return
	
	manager.cleanup_tracking(new_node)
	
	# Erase dictionary entry at the end to allow for dictionary value grabbing beforehand.
	tracked_nodes.erase(new_node)

# -------------------------------------------------------------
# ================= Helper Methods ============================
# -------------------------------------------------------------
