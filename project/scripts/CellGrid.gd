class_name CellGrid

extends Node2D

enum ALGORITHM { PRIM, KRUSKAL} #, BACK_TRCR }
const ALG_NAMES : Dictionary = {
	ALGORITHM.PRIM: "Prim",
	ALGORITHM.KRUSKAL : "Kruskal",
	#ALGORITHM.BACK_TRCR: "Backtracer"
}
const ALG_FUNCS : Dictionary = {
	ALG_NAMES[ALGORITHM.PRIM] : "prim",
	ALG_NAMES[ALGORITHM.KRUSKAL] : "kruskal",
	#ALG_NAMES[ALGORITHM.BACK_TRCR] : "backtracer_iter"
}

var cells : Array = []
var count : int = 0
var cols : int = -1
var rows : int = -1

func _init(r:int, c:int, p:Vector2 = Vector2.ZERO) -> void:
	self.rows = r
	self.cols = c
	self.count=r*c
	
	for _y in range(0, self.rows):
		var row : Array = []
		
		for _x in range(0, self.cols):
			row.append(null)
			
		self.cells.append(row)
	
	self.position = p

func _ready() -> void:
	for r in range(0, self.rows):
		for c in range(0, self.cols):
			var p : Vector2 = Vector2(c, r)
			var i = cell_pos_to_id(p)
			var pos = (Vector2(c, r) * Cell.SIZE/2) + Cell.SIZE/4 #why +SIZE/4? NO IDEA off to a great start
			var type = Cell.CELL_TYPE.DISCONNECTED
			
			var n_i : Array = []
			for n in Cell.NEIGHBORS.values():
				var pos_delta : Vector2 = Cell.get_neighbor_pos_delta(n)
				var gianni : int = cell_pos_to_id(p + pos_delta)
				n_i.append(gianni)
			
			var cell : Cell = Cell.new(pos, p, i, n_i, type) 
			call_deferred("add_child", cell)
			self.cells[r][c] = cell

func generate(alg : String):
	reset_cells()
	var start = OS.get_system_time_msecs()
	
	call(ALG_FUNCS[alg])
	
	var end = OS.get_system_time_msecs()
	
	print(abs(start - end))

func get_shuffled_edge_list() -> Array:
	var output : Array = []
	
	for i in range(0, self.count-1):
		var p : Vector2 = cell_id_to_pos(i)

		if (p.x < self.cols-1):
			var h_edge : Array = [i, i+1]
			output.append(h_edge)

		if (p.y < self.rows-1):
			var v_edge : Array = [i, i+self.cols]
			output.append(v_edge)
	
	output.shuffle()

	return output

func reset_cells() -> void:
	for row in self.cells:
		for cell in row:
			cell.reset()

func get_cell_at(p : Vector2) -> Cell:
	return self.cells[int(p.y)][int(p.x)]

func get_cell_by_id(i : int) -> Cell:
	return get_cell_at(cell_id_to_pos(i))

func cell_pos_to_id(p : Vector2) -> int:
	var i : int = int(p.y)*self.cols + int(p.x)
	return i if (p.x in range(0, self.cols)) and (p.y in range(0, self.rows)) else -1
	
func cell_id_to_pos(i : int) -> Vector2:
	var output : Vector2 = Vector2.ZERO
	
	output.y = i / self.cols #row
	output.x = i % self.cols #column
	
	return output

func get_neighbor_for_cell(cell : Cell, n) -> Cell:
	if cell.has_neighbor(n):
		var pos : Vector2 = cell.get_neighbor_pos(n)
		return get_cell_at(pos)
	
	return null

func get_radom_neighbor_for_cell(cell : Cell) -> int:
	var ns : Array = Cell.NEIGHBORS.values().duplicate(true)
	ns.shuffle()
	
	for n in ns:
		if cell.has_neighbor(n):
			return n
	
	return -1
	
func get_random_cell() -> Cell:
	var r = randi() % self.rows
	var c = randi() % self.cols
	return get_cell_at(Vector2(c, r))
	
func prim() -> void:
	var start : Cell = get_random_cell()
	start.type = Cell.CELL_TYPE.CONNECTED
	
	var frontier : Array = []
	for n in start.available_neighbors:
		frontier.append(get_neighbor_for_cell(start, n))
	
	while not(frontier.empty()):
		var p : int = randi() % frontier.size()
		var next : Cell = frontier[p]
		frontier.remove(p)
		
		for n in next.available_neighbors:
			var neigh : Cell = get_neighbor_for_cell(next, n)
			if neigh.type == Cell.CELL_TYPE.CONNECTED and next.type != Cell.CELL_TYPE.CONNECTED:
				next.connect_to_neighbor(neigh)
			elif neigh.type == Cell.CELL_TYPE.DISCONNECTED:
				frontier.append(neigh)

func kruskal() -> void:
	var edges : Array = get_shuffled_edge_list()
	
	for e in edges:
		var cell1 : Cell = get_cell_by_id(e[0])
		var cell2 : Cell = get_cell_by_id(e[1])
	 
		if (cell1.kruskal_merge_with(cell2)):
			cell1.connect_to_neighbor(cell2)

func backtracer_iter() -> void:
	var start : Cell = get_random_cell()
	start.type = Cell.CELL_TYPE.CONNECTED
	
	var stack : Array = [start]
	
	while not(stack.empty()):
		var current : Cell = stack.pop_front()
		print(current.id, " ", current.grid_pos)
		for n in current.available_neighbors:
			var neighbor : Cell = get_neighbor_for_cell(current, n)
			
			if neighbor.type == Cell.CELL_TYPE.DISCONNECTED:
				current.connect_to_neighbor(neighbor)
				stack.push_front(current)
				stack.push_front(neighbor)

func backtracer_rec() -> void:
	bktrcr_rec_main(get_random_cell())
	
func bktrcr_rec_main(current : Cell) -> void:
	for n in current.available_neighbors:
		var neighbor : Cell = get_neighbor_for_cell(current, n)
		
		if neighbor.type == Cell.CELL_TYPE.DISCONNECTED:
			current.connect_to_neighbor(neighbor)
			bktrcr_rec_main(neighbor)

