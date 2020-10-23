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
			
			var cell : Cell = Cell.new(pos, Vector2(c, r), i, type) 
			call_deferred("add_child", cell)
			self.cells[r][c] = cell

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("generate"):
		reset_cells()
		
		backtracer_rec()
	elif Input.is_action_just_pressed("connect_next"):
		boh()

func reset_cells() -> void:
	for row in self.cells:
		for cell in row:
			cell.reset()

func boh():
	var r = randi() % self.rows
	var c = randi() % self.cols
	
	var n = Cell.NEIGHBORS.values()[randi() % Cell.NEIGHBORS.values().size()]
	
	connect_cell(r, c, n)
		
func get_neighbor_pos(r:int, c:int, n) -> Vector2:
	if has_neighbor(r, c, n):
		var pos_delta : Vector2 = Cell.get_neighbor_pos_delta(n)
		return Vector2(c + int(pos_delta.x), r + int(pos_delta.y))
	
	return Vector2.ZERO

func get_neighbor_for_cell_at(r:int, c:int, n) -> Cell:
	if has_neighbor(r, c, n):
		var pos : Vector2 = get_neighbor_pos(r, c, n)
		return self.cells[pos.y][pos.x]
	
	return null

func has_neighbor(r:int, c:int, n) -> bool:
	return not((n == Cell.NEIGHBORS.TOP and r == 0) or \
	   (n == Cell.NEIGHBORS.BOTTOM and r == self.rows-1) or \
	   (n == Cell.NEIGHBORS.LEFT and c == 0) or \
	   (n == Cell.NEIGHBORS.RIGHT and c == self.cols-1))

func connect_cell(r:int, c:int, n:int) -> void:
	if has_neighbor(r, c, n):
		var cell1 : Cell = self.cells[r][c]
		var cell2 : Cell = get_neighbor_for_cell_at(r, c, n)
		
		connect_cells(cell1, cell2, n)

func connect_cells(cell1 : Cell, cell2 : Cell, n) -> void:
	cell1.connect_to_neighbor(n)
	cell2.connect_to_neighbor(Cell.get_complementary_neighbor(n))
	
	cell1.update()
	cell2.update()

func backtracer_rec() -> void:
	var r = randi() % self.rows
	var c = randi() % self.cols
	
	bktrcr_rec_main(r,c)
	
func bktrcr_rec_main(r:int, c:int) -> void:
	var current : Cell = self.cells[r][c]
	
	var neighbors = Cell.NEIGHBORS.values().duplicate(true)
	neighbors.shuffle()
	
	for n in neighbors:
		if has_neighbor(r,c,n):
			var neighbor : Cell = get_neighbor_for_cell_at(r, c, n)
			var n_pos : Vector2 = get_neighbor_pos(r, c, n)
			
			if neighbor.type == Cell.CELL_TYPE.DISCONNECTED:
				connect_cells(current, neighbor, n)
				bktrcr_rec_main(n_pos.y, n_pos.x)

