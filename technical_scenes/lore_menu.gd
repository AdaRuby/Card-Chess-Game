extends Control

@onready var button_sound: AudioStreamPlayer = $button_sound

func _ready():
	#get_viewport().size = DisplayServer.screen_get_size()
	pass
	
func _on_back_button_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://technical_scenes/start_menu.tscn")
