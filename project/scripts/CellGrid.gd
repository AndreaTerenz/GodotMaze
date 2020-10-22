class_name CellGrid

extends Node2D

var cells : Array = []
var count = 0
var cols = -1
var rows = -1

func _init(r:int, c:int, p:Vector2 = Vector2.ZERO) -> void:
	self.rows = r
	self.cols = c
	self.count=r*c
	
	for y in range(0, self.rows):
		var row : Array = []
		
		for x in range(0, self.cols):
			row.append(null)
			
		self.cells.append(row)
	
	self.position = p

func _ready() -> void:
	var start_idx = randi() % int(self.rows * self.cols)
	
	for r in range(0, self.rows):
		for c in range(0, self.cols):
			var i = int(r*self.cols + c)
			var pos = (Vector2(c, r) * Cell.SIZE/2) + Cell.SIZE/4 #why +SIZE/4? NO IDEA off to a great start
			var type = Cell.CELL_TYPE.DISCONNECTED# if (i != start_idx) else Cell.CELL_TYPE.START
			
			var cell : Cell = Cell.new(pos, i, type) 
			call_deferred("add_child", cell)
			self.cells[r][c] = cell

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("connect_next"):
		boh()

func boh():
	var r = randi() % self.rows
	var c = randi() % self.cols
	
	var n = Cell.NEIGHBORS.values()[randi() % Cell.NEIGHBORS.values().size()]
	
	connect_cell(r, c, n)

func get_neighbor_pos_delta(n) -> Vector2:
	match(n):
		Cell.NEIGHBORS.LEFT:    return Vector2(-1, 0)
		Cell.NEIGHBORS.RIGHT: return Vector2(1, 0)
		Cell.NEIGHBORS.TOP:   return Vector2(0, -1)
		Cell.NEIGHBORS.BOTTOM:  return Vector2(0, 1)
		_: return Vector2.ZERO

func connect_cell(r:int, c:int, n:int) -> void:
	if (n == Cell.NEIGHBORS.TOP and r == 0) or \
	   (n == Cell.NEIGHBORS.BOTTOM and r == self.rows-1) or \
	   (n == Cell.NEIGHBORS.LEFT and c == 0) or \
	   (n == Cell.NEIGHBORS.RIGHT and c == self.cols-1): return
	
	var cell2_delta : Vector2 = get_neighbor_pos_delta(n)
	var cell1 : Cell = self.cells[r][c]
#	print("(row, column): " + str(Vector2(c, r)) + " | neighbor: " + str(Cell.NEIGHBORS.keys()[n]) + \
#		 " | (n_row, n_col): "+ str(Vector2(c, r) + cell2_delta) + " | n_pos_delta: " + str(cell2_delta))
	var cell2 : Cell = self.cells[r + int(cell2_delta.y)][c + int(cell2_delta.x)]
	
	cell1.connect_to_neighbor(n)
	cell2.connect_to_neighbor(Cell.get_complementary_neighbor(n))
	
	cell1.update()
	cell2.update()
