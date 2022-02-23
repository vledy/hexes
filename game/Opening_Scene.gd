extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_PlayButton_pressed():
	get_tree().change_scene("Main_Game_Scene.tscn")


func _on_SettingsButton_pressed():
	get_tree().change_scene("Settings_Scene.tscn")
