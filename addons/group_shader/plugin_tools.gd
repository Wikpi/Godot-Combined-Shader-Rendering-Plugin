tool
extends EditorPlugin

# `get_node_sprites` computes a full list sprites for a given root node.
static func get_sprites(root_node) -> Array:
	var sprite_list: Array = []
	
	# Compute a list of only visible sprites
	if root_node is Sprite && root_node.visible && !root_node.name.begins_with("MergedSprite"):
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

static func merge_sprites(parent: Node2D, sprites: Array) -> Sprite:
	var bounds = calculate_sprite_bounds(sprites)
	var merged_viewport = create_merged_viewport(bounds.size)

	var sprite_container = create_cloned_sprite_container(sprites, bounds.min)
	
	merged_viewport.add_child(sprite_container)

	var result_sprite = create_result_sprite(merged_viewport.get_texture(), bounds.size / 2 + bounds.min)
	
	var grandparent := parent.get_parent()
	if grandparent:
		grandparent.add_child(merged_viewport)
		grandparent.add_child(result_sprite)
#		grandparent.call_deferred("add_child", result_sprite)

	if parent.material is ShaderMaterial:
		result_sprite.material = parent.material.duplicate()

	return result_sprite

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

static func create_merged_viewport(size: Vector2) -> Viewport:
	var viewport := Viewport.new()
	
	viewport.name = "MergedViewport"
	viewport.size = size
	viewport.transparent_bg = true
	viewport.render_target_v_flip = true
	viewport.own_world = true
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	
	return viewport

static func create_cloned_sprite_container(sprites: Array, offset: Vector2):
	var container := Node2D.new()
	container.position = -offset  # Apply offset to align with world origin
	
	for sprite in sprites:
		if !sprite.texture:
			continue

		var clone := Sprite.new()

		clone.texture = sprite.texture
		clone.scale = sprite.scale
		clone.centered = sprite.centered
		clone.rotation = sprite.rotation
		clone.modulate = sprite.modulate
		clone.region_enabled = sprite.region_enabled
		clone.region_rect = sprite.region_rect
		
		clone.transform = sprite.get_global_transform()

		container.add_child(clone)

	return container

static func create_result_sprite(texture: Texture, position: Vector2) -> Sprite:
	var result := Sprite.new()
	
	result.name = "MergedSprite"
	result.texture = texture
	result.position = position
	
	return result

static func cleanup_node(node) -> void:
	var grandparent = node.get_parent()
	
	for child in grandparent.get_children():
		if child.name.begins_with("MergedViewport") or child.name.begins_with("MergedSprite"):
			child.queue_free()
