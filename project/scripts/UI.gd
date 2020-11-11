extends Control

signal reset
signal generate(alg)

onready var grid_ctrls := $ColorRect/MainContainer/GridCtlCont
onready var alg_chooser := $ColorRect/MainContainer/AlgChoicheCont/AlgorithmChoiche

func _ready() -> void:
	var names := CellGrid.ALG_NAMES
	var k = names.keys()
	k.sort()
	
	for i in k:
		alg_chooser.add_item(names[i], i)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_ui"):
		self.visible = !self.visible

func get_selected_alg() -> String:
	var id = alg_chooser.get_selected_id()
	var idx = alg_chooser.get_item_index(id)
	
	return alg_chooser.get_item_text(idx)

func toggle_grid_ctrls(d := true) -> void:
	self.grid_ctrls.propagate_call("set", ["disabled", d], false)

func _on_GenerateBtn_pressed() -> void:
	toggle_grid_ctrls()
	emit_signal("generate", get_selected_alg())

func _on_ResetBtn_pressed() -> void:
	emit_signal("reset")

func _on_Grid_maze_done() -> void:
	toggle_grid_ctrls(false)
