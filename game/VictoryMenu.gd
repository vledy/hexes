extends PopupPanel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.

var unpressed: bool = false
signal reset_game

func _ready():
	pass

func open_popup(winning_player):
	get_node("TextItems/MenuLabel").set_text("PLAYER " + winning_player + " WINS!")
	show()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_ExitToOpeningButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("Opening_Scene.tscn")


func _on_NewGameButton_pressed():
	self.hide()
	self.unpressed = false
	get_tree().paused = false
	emit_signal("reset_game")

