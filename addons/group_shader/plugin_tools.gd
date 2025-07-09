tool
extends EditorPlugin

# `get_node_sprites` computes a full list sprites for a given root node.
static func get_sprites(root_node) -> Array:
	var sprite_list: Array = []
	
	# Compute a list of only visible sprites
	if root_node is Sprite && root_node.visible:
		sprite_list.append(root_node)
	
	# Recursively check each root node child
	for child in root_node.get_children():
		if !(child is Node2D):
			continue
			
		sprite_list += get_sprites(child)
	
	return sprite_list

# `generate_node_signature` creates a unique signature token for a given node's sprite list.
# The purpose of this signature is to determine whether the node's overall structure has changed.
static func generate_node_signature(sprites: Array) -> String:
	var signature: String = ""
	
	for sprite in sprites:
		# Invalid sprites do not affect the root node
		if !sprite.texture:
			continue
		
		signature += "%s:%s:%s:%s:%s;" % [
			str(sprite.texture.get_rid()), \
			str(sprite.position), \
			str(sprite.scale), \
			str(sprite.rotation), \
			str(sprite.modulate)
		]
	
	return signature

static func calculate_sprite_bounds(sprites: Array) -> Dictionary:
	if sprites.empty():
		return {"min": Vector2.ZERO, "size": Vector2.ZERO}

	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF

	for sprite in sprites:
		if !sprite.texture:
			continue

		var tex_size = sprite.texture.get_size() * sprite.scale.abs()
		var center = sprite.global_position
		
		var top_left = center - tex_size * 0.5
		var bottom_right = center + tex_size * 0.5

		min_x = min(min_x, top_left.x)
		min_y = min(min_y, top_left.y)
		max_x = max(max_x, bottom_right.x)
		max_y = max(max_y, bottom_right.y)
		
		var size = Vector2(max_x - min_x, max_y - min_y).ceil()

	var min_pos = Vector2(min_x, min_y)
	var size = Vector2(max_x - min_x, max_y - min_y).ceil()
	
	return {
		"min": min_pos,
		"size": size
	}
