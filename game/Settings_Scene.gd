extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#World's laziest programming! I'll clean this up when I'm not trying to figure out other things about Godot.
enum GameModes {PVP = 0, AI = 1, SIMULATION = 2}

var settings_game_mode := 0
var settings_player_ct := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.settings_game_mode = globals.game_mode
	self.settings_player_ct = globals.player_ct

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_PvPModeButton_pressed():
	self.settings_game_mode = GameModes.PVP


func _on_AIModeButton_pressed():
	self.settings_game_mode = GameModes.AI


func _on_SimulationModeButton_pressed():
	self.settings_game_mode = GameModes.SIMULATION


func _on_2PlayersButton_pressed():
	self.settings_player_ct = 2


func _on_3PlayersButton_pressed():
	self.settings_player_ct = 3


func _on_4PlayersButton_pressed():
	self.settings_player_ct = 4


func _on_SaveSettingsButton_pressed():
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("settings", "mode", self.settings_game_mode)
	config.set_value("settings", "player_ct", self.settings_player_ct)
	config.save("user://settings.cfg")
	
	globals.game_mode = self.settings_game_mode
	globals.player_ct = self.settings_player_ct


func _on_BackButton_pressed():
	get_tree().change_scene("Opening_Scene.tscn")
	

