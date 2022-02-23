extends Node

enum TileTypes {BARRIER = 0, INNER_CAPTURE = 1, OUTER_CAPTURE = 3, STANDARD = 4}

#Location on tile, tile type, select state, and adjacent tiles
var tile_type: int
var is_selected := false

var position: Vector2

var x: float
var y: float

#Neighbor nodes are retrieved by calling get_node() on a valid string name.
var ne: String
var e: String
var se: String
var sw: String
var w: String
var nw: String

var occupant: int = -1
var adjacents: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init_values(cell, tile_type, valid_cells):
	self.position = cell
	self.x = cell.x
	self.y = cell.y
	self.tile_type = tile_type
	var tile_ne = Vector2(cell.x + 1 if int(cell.y) % 2 == 1 else cell.x, cell.y - 1)
	var tile_e = Vector2(cell.x + 1, cell.y)
	var tile_se = Vector2(cell.x + 1 if int(cell.y) % 2 == 1 else cell.x, cell.y + 1)
	var tile_sw = Vector2(cell.x - 1 if int(cell.y) % 2 == 0 else cell.x, cell.y + 1)
	var tile_w = Vector2(cell.x - 1, cell.y)
	var tile_nw = Vector2(cell.x - 1 if int(cell.y) % 2 == 0 else cell.x, cell.y - 1)

	self.ne = "node" + str(tile_ne.x) + "-" + str(tile_ne.y) if tile_ne in valid_cells else "empty"
	self.e = "node" + str(tile_e.x) + "-" + str(tile_e.y) if tile_e in valid_cells else "empty"
	self.se = "node" + str(tile_se.x) + "-" + str(tile_se.y) if tile_se in valid_cells else "empty"
	self.sw = "node" + str(tile_sw.x) + "-" + str(tile_sw.y) if tile_sw in valid_cells else "empty"
	self.w = "node" + str(tile_w.x) + "-" + str(tile_w.y) if tile_w in valid_cells else "empty"
	self.nw = "node" + str(tile_nw.x) + "-" + str(tile_nw.y) if tile_nw in valid_cells else "empty"
	
	self.adjacents.append(self.ne)
	self.adjacents.append(self.e)
	self.adjacents.append(self.se)
	self.adjacents.append(self.sw)
	self.adjacents.append(self.w)
	self.adjacents.append(self.nw)

func has_ne():
	return self.ne != null and self.ne != "empty"

func has_e():
	return self.e != null and self.e != "empty"

func has_se():
	return self.se != null and self.se != "empty"

func has_sw():
	return self.sw != null and self.sw != "empty"

func has_w():
	return self.w != null and self.w != "empty"

func has_nw():
	return self.nw != null and self.nw != "empty"

func is_empty():
	return true if self.occupant == -1 else false

func get_occupant():
	if !self.occupant in [-1, 0, 1, 2, 3]:
		self.occupant = -1
	return self.occupant
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
