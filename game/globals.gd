extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_mode := 0
var player_ct := 2

#Game mode enums for easier readability. AI = player v. AI, simulation = full AI play
enum GameModes {PVP = 0, AI = 1, SIMULATION = 2}

# Called when the node enters the scene tree for the first time.
func _ready():
	#Load the configuration file if it exists, and create a new one
	#with default settings if it does not
	load_config()

func load_config():
	var directory = Directory.new()
	var config_exists = directory.file_exists("user://settings.cfg")
	if !config_exists:
		var config = ConfigFile.new()
		config.set_value("settings", "mode", GameModes.PVP)
		config.set_value("settings", "player_ct", 2)
		config.save("user://settings.cfg")
		
		self.game_mode = GameModes.PVP #This is redundant, but setting defaults here in case I change the above
		self.player_ct = 2
		
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		self.game_mode = config.get_value("settings", "mode", GameModes.PVP)
		self.player_ct = config.get_value("settings", "player_ct", 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
