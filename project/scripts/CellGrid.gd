class_name CellGrid

extends Node2D

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
			var i = get_id_for_cell_at(p)
			var pos = (Vector2(c, r) * Cell.SIZE/2) + Cell.SIZE/4 #why +SIZE/4? NO IDEA off to a great start
			var type = Cell.CELL_TYPE.DISCONNECTED
			
			var n_i : Array = []
			for n in Cell.NEIGHBORS.values():
				n_i.append(get_id_for_cell_neighbor(p, n))
			
			var cell : Cell = Cell.new(pos, p, i, n_i, type) 
			call_deferred("add_child", cell)
			self.cells[r][c] = cell

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("generate"):
		reset_cells()
		var start = OS.get_system_time_msecs()
		
		prim()
		#kruskal()
		#backtracer_iter()
		
		#backtracer_rec()
		
		var end = OS.get_system_time_msecs()
		
		print(abs(start - end))
		
	elif Input.is_action_just_pressed("connect_next"):
		pass#boh()

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

func get_id_for_cell_at(p : Vector2) -> int:
	return int(p.y)*self.cols + int(p.x)

func cell_id_to_pos(i : int) -> Vector2:
	var output : Vector2 = Vector2.ZERO
	
	output.y = i / self.cols #row
	output.x = i % self.cols #column
	
	return output

func get_id_for_cell_neighbor(p : Vector2, n) -> int:
	if has_neighbor(p, n):
		var pos_delta : Vector2 = Cell.get_neighbor_pos_delta(n)
		return get_id_for_cell_at(p - pos_delta)
	
	return -1

func get_neighbor_for_cell(cell : Cell, n) -> Cell:
	if has_neighbor(cell.grid_pos, n):
		var pos : Vector2 = cell.get_neighbor_pos(n)
		return get_cell_at(pos)
	
	return null

func has_neighbor(pos : Vector2, n) -> bool:
	var r = int(pos.y)
	var c = int(pos.x)
	
	return not((n == Cell.NEIGHBORS.TOP and r == 0) or \
	   (n == Cell.NEIGHBORS.BOTTOM and r == self.rows-1) or \
	   (n == Cell.NEIGHBORS.LEFT and c == 0) or \
	   (n == Cell.NEIGHBORS.RIGHT and c == self.cols-1))

func get_radom_neighbor_for_cell(cell : Cell) -> int:
	var ns : Array = Cell.NEIGHBORS.values().duplicate(true)
	ns.shuffle()
	
	for n in ns:
		if has_neighbor(cell.grid_pos, n):
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
	for n in Cell.NEIGHBORS.values():
		if has_neighbor(start.grid_pos, n):
			frontier.append(get_neighbor_for_cell(start, n))
	
	while not(frontier.empty()):
		var p : int = randi() % frontier.size()
		var next : Cell = frontier[p]
		frontier.remove(p)
		
		var ns : Array = []
		var n_vals = Cell.NEIGHBORS.values().duplicate()
		n_vals.shuffle()
		
		for n in n_vals:
			if has_neighbor(next.grid_pos, n):
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
	var neighbors : Array = Cell.get_shuffled_neighbors()
	
	while not(stack.empty()):
		var current : Cell = stack.pop_front()
		
		for n in neighbors:
			if has_neighbor(current.grid_pos, n):
				var neighbor : Cell = get_neighbor_for_cell(current, n)
				
				if neighbor.type == Cell.CELL_TYPE.DISCONNECTED:
					current.connect_to_neighbor(neighbor)
					stack.push_front(current)
					stack.push_front(neighbor)
					
		neighbors.shuffle()

func backtracer_rec() -> void:
	bktrcr_rec_main(get_random_cell())
	
func bktrcr_rec_main(current : Cell) -> void:
	var neighbors = Cell.get_shuffled_neighbors()
	
	for n in neighbors:
		if has_neighbor(current.grid_pos, n):
			var neighbor : Cell = get_neighbor_for_cell(current, n)
			
			if neighbor.type == Cell.CELL_TYPE.DISCONNECTED:
				current.connect_to_neighbor(neighbor)
				bktrcr_rec_main(neighbor)

