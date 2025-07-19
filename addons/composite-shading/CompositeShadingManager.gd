#extends Node2D
#
#tool
#class_name CompositeShadingSprite
#
#export(NodePath) var tracked_root_path: NodePath
#export(bool) var enabled := true
#
#var viewport := null
#var texture_sprite := null
#
#func _ready():
#	if Engine.is_editor_hint():
#		return
#
#	if not enabled:
#		return
#
#	setup_composite_runtime()
#
#func setup_composite_runtime():
#	if not tracked_root_path:
#		printerr("CompositeShadingSprite: No tracked root path set")
#		return
#
#	var tracked_node = get_node_or_null(tracked_root_path)
#	if not tracked_node:
#		printerr("CompositeShadingSprite: Tracked node not found")
#		return
#
#	setup_viewport(tracked_node)
#	update_composite_position(tracked_node)
#
#func setup_viewport(target_node):
#	if viewport:
#		viewport.queue_free()
#	if texture_sprite:
#		texture_sprite.queue_free()
#
#	viewport = Viewport.new()
#	viewport.size = target_node.get_combined_minimum_size()
#	viewport.disable_3d = true
#	viewport.transparent_bg = true
#	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
#	add_child(viewport)
#
#	# Clone target node into viewport
#	var clone := target_node.duplicate()
#	viewport.add_child(clone)
#
#	texture_sprite = Sprite.new()
#	texture_sprite.texture = viewport.get_texture()
#	add_child(texture_sprite)
#
#func update_composite_position(tracked_node):
#	global_position = tracked_node.global_position
