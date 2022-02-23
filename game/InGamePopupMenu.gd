extends PopupPanel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.

var unpressed: bool = false

signal pause_close_clicked

func _ready():
	pass

func open_popup():
	show()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_CloseButton_pressed():
	self.hide()
	self.unpressed = false
	get_tree().paused = false
	emit_signal("pause_close_clicked")

func _input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		if !event.pressed:
			self.unpressed = true
		if event.pressed and self.unpressed:
			self.hide()
			get_tree().paused = false
			self.unpressed = false
	

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_ExitToOpeningButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("Opening_Scene.tscn")

