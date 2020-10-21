class_name Cell

extends Node2D

const SIDE = 30
const SIZE : Vector2 = Vector2(SIDE, SIDE)

var top_left : Vector2 = Vector2(-1, -1)

func setup(p : Vector2) -> void:
	self.position = p
	self.top_left = self.position - SIZE/2

func _draw() -> void:
	var r : Rect2 = Rect2(self.top_left, SIZE)
	draw_rect(r, Color(0, 0, 0), false, 3.0)
	draw_rect(r, Color(255, 255, 255))
	"""
	draw_circle(self.position, 4, Color.white)
	draw_circle(self.top_left, 4, Color.blue)
	"""
