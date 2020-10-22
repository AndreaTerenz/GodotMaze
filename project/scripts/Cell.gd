class_name Cell

extends Node2D

enum CELL_TYPE {START, CONNECTED, DISCONNECTED}
enum NEIGHBORS {TOP, LEFT, BOTTOM, RIGHT}

const SIDE = 30
const SIZE : Vector2 = Vector2(SIDE, SIDE)

var top_left : Vector2 = Vector2(-1, -1)
var type = CELL_TYPE.DISCONNECTED
var connections : Array = [false, false, false, false]
var id : int = -1

func setup(p : Vector2, i : int, t = CELL_TYPE.DISCONNECTED) -> void:
	self.position = p
	self.top_left = self.position - SIZE/2
	self.type = t
	self.id = i
	
func get_color_for_type() -> Color:
	match (self.type):
		CELL_TYPE.CONNECTED : return Color(255, 255, 255)
		CELL_TYPE.DISCONNECTED : return Color(0, 0, 0)
		CELL_TYPE.START : return Color(0, 255, 0)
		
	return Color(0)
	
func connect_to_neighbor():
	pass

func _draw() -> void:
	var r : Rect2 = Rect2(self.top_left, SIZE)
	
	if (self.type == CELL_TYPE.DISCONNECTED):
		draw_rect(r, Color(255, 255, 255), false, 3.0)
	else:
		draw_rect(r, Color(0, 0, 0), false, 3.0)
	
	draw_rect(r, get_color_for_type())
	"""
	draw_circle(self.position, 4, Color.white)
	draw_circle(self.top_left, 4, Color.blue)
	"""
