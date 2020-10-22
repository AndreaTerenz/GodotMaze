class_name CellGrid

extends Node2D

export(PackedScene) var cell_scn = preload("res://scenes/Cell.tscn")

var cells : Array = []
var size : Vector2 = Vector2.ZERO
var cols = -1
var rows = -1

func _init(r:int, c:int, p:Vector2 = Vector2.ZERO) -> void:
	self.rows = r
	self.cols = c
	
	for y in range(0, self.size.y):
		var row : Array = []
		
		for x in range(0, self.size.x):
			row.append(null)
			
		self.cells.append(row)
	
	self.position = p

func _ready() -> void:
	var start_idx = randi() % int(self.rows * self.cols)
	
	for y in range(0, self.rows):
		for x in range(0, self.cols):
			var i = int(y*self.cols + x)
			var pos = (Vector2(x, y) * Cell.SIZE/2) + Cell.SIZE/4 #why +SIZE/4? NO IDEA off to a great start
			var type = Cell.CELL_TYPE.DISCONNECTED if (i != start_idx) else Cell.CELL_TYPE.START
			
			var c : Cell = cell_scn.instance()
			c.setup(pos, i, type) 
			call_deferred("add_child", c)
