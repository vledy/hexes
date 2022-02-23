extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_count := 0 #number of players
var human_player_count := 0
var player_ids := []
var human_players := []
var player0_auto_start := false #used to force user player to be first in AI mode

var turn_count = 1 #keeps track of the number of turns

enum PlayerColors {BROWN = 0, RED = 1, WHITE = 2, GREEN = 3}
enum TileTypes {BARRIER = 0, INNER_CAPTURE = 1, OUTER_CAPTURE = 3, STANDARD = 4}
enum Dirs {NE = 0, E = 1, SE = 2, SW = 3, W = 4, NW = 5}
var player_color_dict = {} #0 = brown, 1 = white, 2 = red, 3 = green
var current_player = 0 #This refers to the player

var inner_tile: Vector2
var outer_tiles = [] #Seriously? No typed arrays, and you call this typing? Lol.
var is_mid_turn = false
var selected_tile: Vector2
var dummy_node: Node

var game_tiles: TileMap
var game_pieces: TileMap
var used_cells: Array
var select_tiles: TileMap

var lock1: bool = false
var bump_calls: int = 0
var in_game_menu
var victory_menu

var victory_menu_open: bool = false
var esc_unpressed: bool = true
var randomize_colors = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	self.game_tiles = get_node("/root/MainGame/GameTiles")
	self.game_pieces = get_node("/root/MainGame/GamePieces")
	self.game_pieces.clear()
	self.select_tiles = get_node("/root/MainGame/SelectedTile")
	self.select_tiles.clear()
	self.used_cells = game_tiles.get_used_cells()
	self.player_count = globals.player_ct
	for i in range(self.player_count):
		player_ids.append(str(i))
	
	self.human_player_count = self.player_count #For now, all players are human
	for i in range(self.human_player_count):
		human_players.append(i)
	randomize_player_colors()
	self.current_player = 0 if self.player0_auto_start else randi() % self.player_count
	update_player_label()
	update_turn_label()
	create_nodes()
	

#Helper function that randomizes player colors
func randomize_player_colors():
	var colors = [0, 1, 2, 3] #Brown || Red || White || Green ...This has changed.
		
	for player in range(self.player_count):
		var idx = randi() % colors.size()
		if self.randomize_colors:
			self.player_color_dict[player] = colors[idx]
			colors.erase(colors[idx])
		else:
			self.player_color_dict[player] = player
			colors.erase(colors[0])

#This will generate NodeData nodes for each tile on the TileMap
func create_nodes():
	var node_data = preload("res://NodeData.tscn")
	var ctr = 0
	
	var dummy = node_data.instance()
	dummy.name = "dummy_node"
	dummy.position = Vector2(-1, -1)
	dummy.x = -1.0
	dummy.y = -1.0
	self.dummy_node = dummy
	get_node("TileData").call_deferred("add_child", dummy)
	
	for cell in self.used_cells:
		var node = node_data.instance()
		node.name = "node" + str(cell.x) + "-" + str(cell.y)
		
		var tile_type = self.game_tiles.get_cell(cell.x, cell.y)
		if tile_type == TileTypes.INNER_CAPTURE:
			self.inner_tile = cell
		if tile_type == TileTypes.OUTER_CAPTURE:
			self.outer_tiles.append(cell) #There should only ever be two
			
		node.init_values(cell, tile_type, self.used_cells)
		get_node("TileData").call_deferred("add_child", node)
		ctr += 1
	
func get_ne(node):
	return get_node("TileData").get_node(node.ne) if node.has_ne() else null

func get_e(node):
	return get_node("TileData").get_node(node.e) if node.has_e() else null

func get_se(node):
	return get_node("TileData").get_node(node.se) if node.has_se() else null

func get_sw(node):
	return get_node("TileData").get_node(node.sw) if node.has_sw() else null

func get_w(node):
	return get_node("TileData").get_node(node.w) if node.has_w() else null

func get_nw(node):
	return get_node("TileData").get_node(node.nw) if node.has_nw() else null
	
func vect_to_node(tile):
	if tile == Vector2(-1, -1):
		return self.dummy_node
		
	return get_node("TileData").get_node("node" + str(tile.x) + "-" + str(tile.y))

func str_to_node(str1):
	return get_node("TileData").get_node(str1)
	
func handle_player_click(clicked_tile):
	var is_finished: bool = false
	if !clicked_tile in self.used_cells:
		return false
	
	var clicked = get_node("TileData").get_node("node" + str(clicked_tile.x) + "-" + str(clicked_tile.y))
	if clicked.is_empty() and !self.is_mid_turn:
		if clicked.tile_type == TileTypes.STANDARD:
			set_pieces(self.current_player, clicked, null, true)
			self.select_tiles.clear()
			is_finished = true
	
	else:
		#If we're in the middle of a turn, do x.
		if self.is_mid_turn:
			#Check to see if empty normal path exists from currently selected tile to clicked
			var valid_path: bool = check_path(vect_to_node(self.selected_tile), clicked)
			if valid_path:
				set_pieces(self.current_player, clicked, vect_to_node(self.selected_tile), true)
				is_finished = true
			else:
				self.is_mid_turn = false
				self.selected_tile = Vector2(-1, -1)
			self.select_tiles.clear()
		
		else:
			var current_occupant = clicked.get_occupant()
			if current_occupant == self.current_player and clicked.tile_type == TileTypes.STANDARD:
				self.is_mid_turn = true
				self.selected_tile = clicked_tile
				self.select_tiles.set_cell(clicked.x, clicked.y, 0)
	
	return is_finished

func remove_selected(rm_vect):
	var x = 1

func check_path(start_node, end_node):
	if !end_node.is_empty() or end_node.tile_type != TileTypes.STANDARD:
		return false
	var is_valid = is_valid_path(start_node, end_node)
	return is_valid
	
#...I'd be better off storing these data in a 2-D array with a dictionary.
func is_valid_path(start, end):
	var valid_node_names = []
	var checked_node = start
	var found = false
	
	while (self.get_ne(checked_node) and self.get_ne(checked_node).is_empty() 
	and self.get_ne(checked_node).tile_type == TileTypes.STANDARD):
		checked_node = self.get_ne(checked_node)
		if checked_node and checked_node.name == end.name:
			found = true
			break
	
	if !found:
		checked_node = start
		while (self.get_e(checked_node) and self.get_e(checked_node).is_empty() 
		and self.get_e(checked_node).tile_type == TileTypes.STANDARD):
			checked_node = self.get_e(checked_node)
			if checked_node and checked_node.name == end.name:
				found = true
				break
	
	if !found:
		checked_node = start
		while (self.get_se(checked_node) and self.get_se(checked_node).is_empty() 
		and self.get_se(checked_node).tile_type == TileTypes.STANDARD):
			checked_node = self.get_se(checked_node)
			if checked_node and checked_node.name == end.name:
				found = true
				break
	
	if !found:
		checked_node = start
		while (self.get_sw(checked_node) and self.get_sw(checked_node).is_empty() 
		and self.get_sw(checked_node).tile_type == TileTypes.STANDARD):
			checked_node = self.get_sw(checked_node)
			if checked_node and checked_node.name == end.name:
				found = true
				break
	
	if !found:
		checked_node = start
		while (self.get_w(checked_node) and self.get_w(checked_node).is_empty() 
		and self.get_w(checked_node).tile_type == TileTypes.STANDARD):
			checked_node = self.get_w(checked_node)
			if checked_node and checked_node.name == end.name:
				found = true
				break
	
	if !found:
		checked_node = start
		while (self.get_nw(checked_node) and self.get_nw(checked_node).is_empty() 
		and self.get_nw(checked_node).tile_type == TileTypes.STANDARD):
			checked_node = self.get_nw(checked_node)
			if checked_node and checked_node.name == end.name:
				found = true
				break
	
	return found
	

func end_turn():
	if self.bump_calls > 0:
		while self.bump_calls > 0:
			yield(get_tree().create_timer(0.1), "timeout")
			self.bump_calls -= 1
	
	var victor = get_victor()
	if victor != -1:
		end_game(victor)
	else:
		self.is_mid_turn = false
		self.selected_tile = Vector2(-1, -1)
		self.current_player = (self.current_player + 1) % self.player_count
		self.turn_count += 1
		
		update_player_label()
		update_turn_label()
		
		self.lock1 = false
		

func update_player_label():
	var player_label = get_node("PlayerLabel")
	var player = self.player_color_dict[self.current_player]
	match player:
		0: 
			player_label.add_color_override("font_color", Color(0.6, 0.45, 0.4, 1))
		1:
			player_label.add_color_override("font_color", Color(0.95, 0.95, 1, 1))
		2:
			player_label.add_color_override("font_color", Color(0.6, 0.4, 0.8, 1))
		3:
			player_label.add_color_override("font_color", Color(0.9, 0.6, 0.5, 1))
	
	player_label.set_text(str(player_ids[self.current_player]) + " : player")
	
func update_turn_label():
	get_node("TurnLabel").set_text(str(self.turn_count) + " : turn")
#Helper function that checks if the victory conditions have been met at the end of each turn.
#Returns the winning player's number if the conditions are met; otherwise, returns -1.
func get_victor():
	var victor: int = -1
	
	#If either outer tile is empty, no win conditions are met
	if vect_to_node(outer_tiles[0]).is_empty() or vect_to_node(outer_tiles[1]).is_empty():
		victor = -1
	
	else:
		#If both outer tiles are occupied by the same player, that player wins
		if vect_to_node(outer_tiles[0]).occupant == vect_to_node(outer_tiles[1]).occupant:
			victor = vect_to_node(outer_tiles[0]).occupant
		#Center tile wins if it is occupied and the outer tiles are mismatched
		#If the center tile is unoccupied, the game continues
		else:
			victor = vect_to_node(inner_tile).occupant if !vect_to_node(inner_tile).is_empty() else -1
	
	return victor

func end_game(winning_player):
	self.lock1 = true
	if !self.victory_menu:
		self.victory_menu = load("res://VictoryMenu.tscn").instance()
		self.victory_menu.name = "victory_menu"
		get_node("VictoryMenu").add_child(self.victory_menu)
		get_node("VictoryMenu/victory_menu").connect("reset_game", self, "_on_reset_game")
	self.esc_unpressed = false
	self.victory_menu_open = true
	self.victory_menu.open_popup(player_ids[winning_player])
	get_tree().paused = true

func set_pieces(current_player, new_node, old_node = null, is_move = false):
	if old_node:
		rm_node(old_node)
	fill_node(current_player, new_node)
	if is_move:
		propagate_move(new_node)
	
func fill_node(current_player, new_node):
	self.game_pieces.set_cell(int(new_node.x), int(new_node.y), self.player_color_dict[current_player])
	new_node.occupant = current_player

func rm_node(old_node):
	self.game_pieces.set_cell(int(old_node.x), int(old_node.y), -1)
	old_node.occupant = -1

func propagate_move(start_node):
	var adj_ct: int = 0
	for i in start_node.adjacents:
		if str_to_node(i) and !str_to_node(i).is_empty():
			adj_ct += 1
	
	if adj_ct >= 3:
		for i in start_node.adjacents:
			if str_to_node(i) and !str_to_node(i).is_empty():
				rm_node(str_to_node(i))
	else:
		if start_node.has_ne() and !get_ne(start_node).is_empty():
			bump_piece(get_ne(start_node), Dirs.NE)
		
		if start_node.has_e() and !get_e(start_node).is_empty():
			bump_piece(get_e(start_node), Dirs.E)
		
		if start_node.has_se() and !get_se(start_node).is_empty():
			bump_piece(get_se(start_node), Dirs.SE)
		
		if start_node.has_sw() and !get_sw(start_node).is_empty():
			bump_piece(get_sw(start_node), Dirs.SW)
		
		if start_node.has_w() and !get_w(start_node).is_empty():
			bump_piece(get_w(start_node), Dirs.W)
		
		if start_node.has_nw() and !get_nw(start_node).is_empty():
			bump_piece(get_nw(start_node), Dirs.NW)

#0 = NE, 1 = E, 2 = SE, 3 = SW, 4 = W, 5 = NW
func bump_piece(bumped_node, direction):
	self.bump_calls += 1
	yield(get_tree().create_timer(0.1), "timeout")
	match direction:
		Dirs.NE:
			if bumped_node.has_ne() and get_ne(bumped_node).is_empty():
				var ne_node: Node = get_ne(bumped_node)
				set_pieces(bumped_node.get_occupant(), ne_node, bumped_node)
				if get_ne(ne_node) and !get_ne(ne_node).is_empty():
					bump_piece(get_ne(ne_node), Dirs.NE)
		Dirs.E:
			if bumped_node.has_e() and get_e(bumped_node).is_empty():
				var e_node: Node = get_e(bumped_node)
				set_pieces(bumped_node.get_occupant(), e_node, bumped_node)
				if get_e(e_node) and !get_e(e_node).is_empty():
					bump_piece(get_e(e_node), Dirs.E)
		Dirs.SE:
			if bumped_node.has_se() and get_se(bumped_node).is_empty():
				var se_node: Node = get_se(bumped_node)
				set_pieces(bumped_node.get_occupant(), se_node, bumped_node)
				if get_se(se_node) and !get_se(se_node).is_empty():
					bump_piece(get_se(se_node), Dirs.SE)
		Dirs.SW:
			if bumped_node.has_sw() and get_sw(bumped_node).is_empty():
				var sw_node: Node = get_sw(bumped_node)
				set_pieces(bumped_node.get_occupant(), sw_node, bumped_node)
				if get_sw(sw_node) and !get_sw(sw_node).is_empty():
					bump_piece(get_sw(sw_node), Dirs.SW)
		Dirs.W:
			if bumped_node.has_w() and get_w(bumped_node).is_empty():
				var w_node: Node = get_w(bumped_node)
				set_pieces(bumped_node.get_occupant(), w_node, bumped_node)
				if get_w(w_node) and !get_w(w_node).is_empty():
					bump_piece(get_w(w_node), Dirs.W)
		Dirs.NW:
			if bumped_node.has_nw() and get_nw(bumped_node).is_empty():
				var nw_node: Node = get_nw(bumped_node)
				set_pieces(bumped_node.get_occupant(), nw_node, bumped_node)
				if get_nw(nw_node) and !get_nw(nw_node).is_empty():
					bump_piece(get_nw(nw_node), Dirs.NW)

#Method of input for mouse clicks
func _unhandled_input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
			if !event.pressed:
				self.esc_unpressed = true
			if event.pressed and self.esc_unpressed and !self.victory_menu_open:
				#get_tree().change_scene("Opening_Scene.tscn") #Eventually replace with popup to go back to main screen
				if !self.in_game_menu:
					self.in_game_menu = load("res://InGamePopupMenu.tscn").instance()
					self.in_game_menu.name = "in_game_popup"
					get_node("InGamePopup").add_child(self.in_game_menu)
					get_node("InGamePopup/in_game_popup").connect("pause_close_clicked", self, "_on_pause_close_clicked")
				self.esc_unpressed = false
				self.in_game_menu.open_popup()
				get_tree().paused = true
			
	var game_tiles = get_node("/root/MainGame/GameTiles")

	if (event is InputEventMouseButton and !event.is_pressed() and (event.button_index == BUTTON_LEFT 
	or event.button_index == BUTTON_RIGHT) and !lock1):
		self.lock1 = true
		if self.current_player in human_players:
			var pos_x = floor((event.position[0] - 85) / 0.25)
			var pos_y = floor((event.position[1] - 35) / 0.25)
			var corrected_vect = Vector2(pos_x, pos_y)
			var clicked_tile = game_tiles.world_to_map(corrected_vect)
			
			var turn_completed = handle_player_click(clicked_tile)
			self.lock1 = false
			
			if turn_completed:
				end_turn()
			

func _on_pause_close_clicked():
	self.esc_unpressed = true

func _on_reset_game():
	self.esc_unpressed = true
	self.victory_menu_open = false
	for tile in self.used_cells:
		vect_to_node(tile).occupant = -1
	self.game_pieces.clear()
	self.turn_count = 1
	self.current_player = 0 if self.player0_auto_start else randi() % self.player_count
	update_player_label()
	update_turn_label()
	self.lock1 = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	continue

func _on_PauseButton_pressed():
	if self.esc_unpressed and !self.victory_menu_open:
		if !self.in_game_menu:
			self.in_game_menu = load("res://InGamePopupMenu.tscn").instance()
			self.in_game_menu.name = "in_game_popup"
			get_node("InGamePopup").add_child(self.in_game_menu)
			get_node("InGamePopup/in_game_popup").connect("pause_close_clicked", self, "_on_pause_close_clicked")
		self.esc_unpressed = false
		self.in_game_menu.open_popup()
		get_tree().paused = true
