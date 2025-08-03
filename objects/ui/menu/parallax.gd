extends Node2D

@export var parallax_elements: Dictionary[String, float] = {}

func _process(delta: float) -> void:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var parallax_origin = global_position
	var distance = mouse_pos - parallax_origin
	distance.x = clamp(distance.x / viewport.size.x, -1.0, 1.0)
	distance.y = clamp(distance.y / viewport.size.y, -1.0, 1.0)
	
	for element in parallax_elements:
		var speed_coef = parallax_elements[element]
		var element_node = get_node(element) as Node2D
		element_node.position = distance * speed_coef
