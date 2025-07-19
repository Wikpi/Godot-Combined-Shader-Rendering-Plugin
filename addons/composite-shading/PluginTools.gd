tool
extends Node2D

class_name CompositeShadingTools

# The meta data label that is attached to a node which has the plugin enabled.
const tracked_node_meta: String = "composite_shading"
# A part of the custom plugin node name. The full name would result in: [node.name]plugin_node_suffix.
const plugin_node_suffix: String = "CompositeShadingSprite"
# Path to the custom plugin icon.
const plugin_icon_path: String = "res://addons/composite-shading/data/PluginIcon.png"

# -------------------------------------------------------------
# ===================== Tools =================================
# -------------------------------------------------------------

# `get_node_sprites` computes a full list sprites for a given root node.
# This includes all recursive children sprites.
static func get_sprites(new_node: Node2D) -> Array:
	# Final sprite list object
	var sprite_list: Array = []
	
	# Compute a list of only visible sprites
	if new_node is Sprite && new_node.visible:
		sprite_list.append(new_node)
	
	# Recursively check each root node child
	for child in new_node.get_children():
		# Current suppoirt is only for Node2D types
		if !(child is Node2D):
			continue
			
		sprite_list += get_sprites(child)
	
	return sprite_list

# `generate_node_signature` creates a unique signature token for a given node's sprite list.
# The purpose of this signature is to determine whether the node's overall structure has changed.
static func generate_node_signature(new_sprites: Array) -> String:
	# Final node signature value
	var signature: String = ""
	
	for sprite in new_sprites:
		# Invalid sprites do not affect the root node
		if !sprite.texture:
			continue
		
		# Include any relevant information that might change for sprites in the signature
		# This specifies what exactly to look for when updating the plugin sprite.
		signature += "%s:%s:%s:%s:%s;" % [
			str(sprite.texture.get_rid()), \
			str(sprite.position), \
			str(sprite.scale), \
			str(sprite.rotation), \
			str(sprite.modulate)
		]
	
	return signature

# `calculate_sprite_bounds` computes the overall bounding limits for the given sprite list.
static func calculate_sprite_bounds(new_sprites: Array) -> Dictionary:
	# Give a null representation. Though this should never be true in practice
	if new_sprites.empty():
		return {"min": Vector2.ZERO, "max": Vector2.ZERO, "size": Vector2.ZERO}
	
	# Top left bounding corner
	var min_x: float = INF
	var min_y: float = INF
	
	# Bottom right bounding corner
	var max_x: float = -INF
	var max_y: float = -INF
	
	# For each sprite redetermine the the bounds
	for sprite in new_sprites:
		# Empty sprites do not change anything
		if !sprite.texture:
			continue

		var sprite_size: Vector2 = sprite.texture.get_size() * sprite.scale.abs()
		var sprite_center: Vector2 = sprite.global_position
		
		# Knowing the position of the center, can determine 
		# the top left and bottom right bounding corners
		var top_left: Vector2 = sprite_center - sprite_size / 2
		var bottom_right: Vector2 = sprite_center + sprite_size / 2
		
		# Taking min of the values ensures its the true top left corner
		min_x = min(min_x, top_left.x)
		min_y = min(min_y, top_left.y)
		
		# Taking max of the values ensures its the true bottom right corner
		max_x = max(max_x, bottom_right.x)
		max_y = max(max_y, bottom_right.y)
	
	return {
		"min": Vector2(min_x, min_y), # Top left corner
		"max": Vector2(max_x, max_y), # Bottom right corner
		"size": Vector2(max_x - min_x, max_y - min_y).ceil() # Pixel perfect size
	}

# `get_meta_data` retreives nodes existing meta data field value. 
static func get_meta_data(new_node: Node2D, field: String, fallback):
	if !new_node.has_meta(tracked_node_meta):
		return fallback
	
	var meta: Dictionary = new_node.get_meta(tracked_node_meta, null)
	if !meta:
		return fallback
	
	if !meta.has(field):
		return fallback
	
	return meta.get(field)

# `set_meta_data` updates nodes meta data field.
static func set_meta_data(new_node: Node2D, field: String, value) -> void:
	var meta: Dictionary = {}
	if new_node.has_meta(tracked_node_meta):
		meta = new_node.get_meta(tracked_node_meta, null)
	
	meta[field] = value
	
	new_node.set_meta(tracked_node_meta, meta)
