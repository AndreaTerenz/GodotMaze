class_name Cell

extends Node2D

enum CELL_TYPE {START, CONNECTED, DISCONNECTED}
enum NEIGHBORS {TOP = 0, LEFT = 1, BOTTOM = 2, RIGHT = 3}

const SIDE = 30
const SIZE : Vector2 = Vector2(SIDE, SIDE)

var top_left : Vector2 = Vector2(-1, -1)
var type = CELL_TYPE.DISCONNECTED
var connections : Array = [false, false, false, false]
var id : int = -1

onready var default_font = Control.new().get_font("font")

func _init(p : Vector2, i : int, t = CELL_TYPE.DISCONNECTED) -> void:
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
	
func connect_to_neighbor(n : int, propagate : bool = true) -> void:
	var set_connected : bool = false
	
	for neigh in NEIGHBORS.values():
		self.connections[neigh] = self.connections[neigh] or (n == neigh)
		set_connected = set_connected or (n == neigh)
		
	if (set_connected and self.type != CELL_TYPE.START):
		self.type = CELL_TYPE.CONNECTED

func draw_borders() -> void:
	var c : Color = Color(0, 0, 0)
	
	for n in NEIGHBORS.values():
		if not(self.connections[n]):
			var start : Vector2 = Vector2.ZERO
			var end : Vector2 = Vector2.ONE
			
			match (n):
				NEIGHBORS.TOP    : end.y = 0
				NEIGHBORS.BOTTOM : start.y = 1
				NEIGHBORS.LEFT   : end.x = 0
				NEIGHBORS.RIGHT  : start.x = 1
				
			start = (start*SIDE) + self.top_left
			end = (end*SIDE) + self.top_left

			draw_line(start, end, c, 3.0)

func _draw() -> void:
	var r : Rect2 = Rect2(self.top_left, SIZE)

	draw_rect(r, get_color_for_type())
	draw_borders()
	
	"""
	draw_string(self.default_font, self.position - Vector2(SIDE/3, 0), str(self.id))
	draw_circle(self.position, 4, Color.white)
	draw_circle(self.top_left, 4, Color.blue)
	"""

static func get_complementary_neighbor(n):
	match (n):
		NEIGHBORS.TOP: return NEIGHBORS.BOTTOM
		NEIGHBORS.BOTTOM: return NEIGHBORS.TOP
		NEIGHBORS.LEFT: return NEIGHBORS.RIGHT
		NEIGHBORS.RIGHT: return NEIGHBORS.LEFT
