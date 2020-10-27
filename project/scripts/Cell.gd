class_name Cell

extends Node2D

enum CELL_TYPE {CONNECTED, DISCONNECTED}
enum NEIGHBORS {TOP = 0, LEFT = 1, BOTTOM = 2, RIGHT = 3}

const SIDE = 15
const SIZE : Vector2 = Vector2(SIDE, SIDE)

var top_left : Vector2 = Vector2.ZERO
var grid_pos : Vector2 = Vector2.ZERO
var neighbors_ids : Array = [-1, -1, -1, -1]
var type = CELL_TYPE.DISCONNECTED
var connections : Array = [null, null, null, null]
var id : int = -1

var kruskal_parent = self

func _init(p : Vector2, g_p : Vector2, i : int, n_i : Array, t = CELL_TYPE.DISCONNECTED) -> void:
	self.position = p
	self.grid_pos = g_p
	self.neighbors_ids = n_i.duplicate(true)
	self.top_left = self.position - SIZE/2
	self.type = t
	self.id = i
	
func reset() -> void:
	self.type = CELL_TYPE.DISCONNECTED
	self.kruskal_parent = self
	for n in NEIGHBORS.values():
		self.connections[n] = null
	update()
	
func get_color_for_type() -> Color:
	match (self.type):
		CELL_TYPE.CONNECTED : return Color(255, 255, 255)
		CELL_TYPE.DISCONNECTED : return Color(0, 0, 0)
		
	return Color(0)

func connect_to_neighbor(neighbor, propagate : bool = true) -> void:
	var n = pos_delta_to_neighbor(neighbor.grid_pos - self.grid_pos)
	self.connections[n] = neighbor
	
	self.type = CELL_TYPE.CONNECTED
	update()

	if (propagate):
		neighbor.connect_to_neighbor(self, false)

func draw_borders() -> void:
	var c : Color = Color(0, 0, 0)
	
	for n in NEIGHBORS.values():
		if (self.connections[n] == null):
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
	var default_font = Control.new().get_font("font")
	draw_string(default_font, self.position - Vector2(SIDE/3, 0), str(self.id))
	draw_circle(self.position, 4, Color.white)
	draw_circle(self.top_left, 4, Color.blue)
	"""
	
func get_neighbor_pos(n) -> Vector2:
	var pos_delta : Vector2 = get_neighbor_pos_delta(n)
	return self.grid_pos + pos_delta

func get_random_neighbor() -> Vector2:
	return get_neighbor_pos(NEIGHBORS.values()[randi() % NEIGHBORS.values().size()])
	
func kruskal_same_set_as(other) -> bool:
	return other.kruskal_find() == kruskal_find()

func kruskal_find() -> Cell:
	var parent = self.kruskal_parent
	
	while parent != parent.kruskal_parent:
		parent = parent.kruskal_parent
	
	return parent

func kruskal_merge_with(other) -> bool:
	var root = self.kruskal_find()
	var other_root = other.kruskal_find()

	if (root != other_root):
		if (root.id < other_root.id):
			other_root.kruskal_parent = root
		else:
			root.kruskal_parent = other_root
			
	return (root != other_root)

static func get_shuffled_neighbors() -> Array:
	var output : Array = NEIGHBORS.values().duplicate(true)
	output.shuffle()
	return output

static func get_complementary_neighbor(n) -> int:
	match (n):
		NEIGHBORS.TOP: return NEIGHBORS.BOTTOM
		NEIGHBORS.BOTTOM: return NEIGHBORS.TOP
		NEIGHBORS.LEFT: return NEIGHBORS.RIGHT
		NEIGHBORS.RIGHT: return NEIGHBORS.LEFT
		_ : return -1

static func pos_delta_to_neighbor(delta : Vector2) -> int:
	match(delta):
		Vector2(-1, 0): return NEIGHBORS.LEFT
		Vector2(1, 0): return NEIGHBORS.RIGHT
		Vector2(0, -1): return NEIGHBORS.TOP
		Vector2(0, 1): return NEIGHBORS.BOTTOM
		_: return -1

static func get_neighbor_pos_delta(n) -> Vector2:
	match(n):
		NEIGHBORS.LEFT:   return Vector2(-1, 0)
		NEIGHBORS.RIGHT:  return Vector2(1, 0)
		NEIGHBORS.TOP:    return Vector2(0, -1)
		NEIGHBORS.BOTTOM: return Vector2(0, 1)
		_: return Vector2.ZERO
