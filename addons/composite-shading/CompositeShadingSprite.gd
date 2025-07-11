tool
extends Node2D

# Node children
onready var viewport: Viewport = $Viewport
onready var shading_sprite: Sprite = $Sprite
onready var viewport_sprites: Node2D = $Viewport/Sprites

# Reference to the static helper plugin tools.
var plugin_tools: GDScript = preload("res://addons/composite-shading/PluginTools.gd")
# Root node that the custom plugin node is copying/merging.
var root_node: Node2D
# Custom node unique instance signature. 
# Signature reflects the changes in the original root node sprites. 
var signature: String

# -------------------------------------------------------------
# =================== Main Methods ============================
# -------------------------------------------------------------

func _ready():
	# Default values for children
	viewport.size = Vector2(64, 64)
	viewport.transparent_bg = true
	viewport.render_target_v_flip = true
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	
	# Sprite could have a reference to teh previous viewport if not fully cleared
	shading_sprite.texture = null

# Only added and ran, when the plugin is enabled for the original node.
func _process(_delta: float):
	if !is_instance_valid(root_node):
		return
	
	# Fetch all children of original root node that are sprites.
	var sprites: Array = plugin_tools.get_sprites(root_node)
	# Check if any sprites changes since last isntance.
	var new_signature: String = plugin_tools.generate_node_signature(sprites)

	if signature == new_signature:
		return
	signature = new_signature
	
	# New bounding limits for the fetched sprites
	var bounds: Dictionary = plugin_tools.calculate_sprite_bounds(sprites)
	
	# Dont crash the plugin if canvas item material is not present
	var root_material: Material = root_node.material
	if root_material:
		modify_sprite_material(root_material.duplicate())
	
	# Adapt viewport to new bounds
	modify_viewport_bounds(bounds.size, -bounds.min)
	
	# Add original sprites to the viewport
	modify_viewport_sprite_container(sprites)
	
	# Display final merged sprite result
	create_merged_sprite(bounds.size / 2 + bounds.min)

# -------------------------------------------------------------
# ================= Helper Methods ============================
# -------------------------------------------------------------

# `modify_viewport_bounds` adapts the custom node viewport child to new bounds.
func modify_viewport_bounds(size: Vector2, offset: Vector2) -> void:
	viewport.size = size
	viewport_sprites.position = offset

# `create_merged_sprite` display the new merged sprite.
func create_merged_sprite(offset: Vector2) -> void:
	var new_texture: Texture = viewport.get_texture()
	if !new_texture:
		return
	
	shading_sprite.texture = new_texture
	shading_sprite.position = offset

# `modify_sprite_material` change the canvas item material for the display sprite.
func modify_sprite_material(new_material: Material) -> void:
	if !(new_material is Material):
		return
		
	shading_sprite.material = new_material

# `modify_viewport_sprite_container` clear old and add new sprites to the viewport.
func modify_viewport_sprite_container(new_sprites: Array) -> void:
	# Clear old sprites in the viewport
	for sprite in viewport_sprites.get_children():
		sprite.queue_free()
	
	# Add new sprite clones
	for sprite in new_sprites:
		# Invisible sprites do not giveany benefit
		if !sprite.texture:
			continue

		viewport_sprites.add_child(clone_sprite(sprite))

# `clone_sprite` copies the given sprite.
# Similar to [object].duplicate() just without copying the sprite children.
func clone_sprite(new_sprite: Sprite) -> Sprite:
	var clone := Sprite.new()

	clone.texture = new_sprite.texture
	clone.scale = new_sprite.scale
	clone.centered = new_sprite.centered
	clone.rotation = new_sprite.rotation
	clone.modulate = new_sprite.modulate
	clone.region_enabled = new_sprite.region_enabled
	clone.region_rect = new_sprite.region_rect

	clone.transform = new_sprite.get_global_transform()
	
	return clone
