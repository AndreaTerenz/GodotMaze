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
			var i = get_id_for_cell_at(r, c)
			var pos = (Vector2(c, r) * Cell.SIZE/2) + Cell.SIZE/4 #why +SIZE/4? NO IDEA off to a great start
			var type = Cell.CELL_TYPE.DISCONNECTED# if (i != start_idx) else Cell.CELL_TYPE.START
			
			var n_i : Array = []
			for n in Cell.NEIGHBORS.values():
				n_i.append(get_id_for_cell_neighbor(r, c, n))
			
			var cell : Cell = Cell.new(pos, Vector2(c, r), i, n_i, type) 
			call_deferred("add_child", cell)
			self.cells[r][c] = cell

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("generate"):
		reset_cells()
		
		backtracer_rec()
	elif Input.is_action_just_pressed("connect_next"):
		pass#boh()

func reset_cells() -> void:
	for row in self.cells:
		for cell in row:
			cell.reset()

func get_cell_at(r:int, c:int) -> Cell:
	return self.cells[r][c]

func get_id_for_cell_at(r:int, c:int) -> int:
	return r*self.cols + c
	
func get_id_for_cell_neighbor(r:int, c:int, n) -> int:
	if has_neighbor(Vector2(r, c), n):
		var pos_delta : Vector2 = Cell.get_neighbor_pos_delta(n)
		return get_id_for_cell_at(r - pos_delta.y, c - pos_delta.x)
	
	return -1

func get_neighbor_for_cell(cell : Cell, n) -> Cell:
	if has_neighbor(cell.grid_pos, n):
		var pos : Vector2 = cell.get_neighbor_pos(n)
		return self.cells[pos.y][pos.x]
	
	return null

func has_neighbor(pos : Vector2, n) -> bool:
	var r = int(pos.y)
	var c = int(pos.x)
	
	return not((n == Cell.NEIGHBORS.TOP and r == 0) or \
	   (n == Cell.NEIGHBORS.BOTTOM and r == self.rows-1) or \
	   (n == Cell.NEIGHBORS.LEFT and c == 0) or \
	   (n == Cell.NEIGHBORS.RIGHT and c == self.cols-1))

func connect_cells(cell1 : Cell, cell2 : Cell, n) -> void:
	cell1.connect_to_neighbor(n)
	cell2.connect_to_neighbor(Cell.get_complementary_neighbor(n))
	
	cell1.update()
	cell2.update()

func backtracer_rec() -> void:
	var r = randi() % self.rows
	var c = randi() % self.cols
	
	bktrcr_rec_main(self.cells[r][c])
	
func bktrcr_rec_main(current : Cell) -> void:
	var neighbors = Cell.NEIGHBORS.values().duplicate(true)
	neighbors.shuffle()
	
	for n in neighbors:
		if has_neighbor(current.grid_pos, n):
			var neighbor : Cell = get_neighbor_for_cell(current, n)
			
			if neighbor.type == Cell.CELL_TYPE.DISCONNECTED:
				connect_cells(current, neighbor, n)
				bktrcr_rec_main(neighbor)

