tool
extends Node2D

onready var viewport: Viewport = $Viewport
onready var merged_sprite: Sprite = $Sprite
onready var viewport_sprites: Node2D = $Viewport/Sprites

var plugin_tools = preload("res://addons/group_shader/plugin_tools.gd")

var root_node: Node2D
var signature: String

func _ready():
	viewport.size = Vector2(64, 64)
	viewport.transparent_bg = true
	viewport.render_target_v_flip = true
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS

func _process(delta):
	if !is_instance_valid(root_node):
		return

	var sprites = plugin_tools.get_sprites(root_node)
	var new_signature = plugin_tools.generate_node_signature(sprites)

	if signature == new_signature:
		return
	
	var bounds = plugin_tools.calculate_sprite_bounds(sprites)
	
	modify_sprite_material(root_node.material.duplicate())
	
	modify_viewport_bounds(bounds.size, -bounds.min)

	modify_viewport_sprite_container(sprites)

	create_merged_sprite(bounds.size / 2 + bounds.min)

func modify_viewport_bounds(size: Vector2, offset: Vector2) -> void:
	viewport.size = size
	viewport_sprites.position = offset

func create_merged_sprite(offset: Vector2) -> void:
	merged_sprite.texture = viewport.get_texture()
	merged_sprite.position = offset

func modify_sprite_material(new_material: Material) -> void:
	if !(new_material is Material):
		return
		
	merged_sprite.material = new_material

func modify_viewport_sprite_container(new_sprites: Array) -> void:
	for sprite in viewport_sprites.get_children():
		sprite.queue_free()
	
	for sprite in new_sprites:
		if !sprite.texture:
			continue

		viewport_sprites.add_child(clone_sprite(sprite))

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
