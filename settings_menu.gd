extends Control

@onready var button_sound: AudioStreamPlayer = $button_sound
@onready var res = $MarginContainer/VBoxContainer/Resolutions
@onready var window_button = $MarginContainer/VBoxContainer/Window_modes

func _ready():
	select_current_window_mode()
	var player_res = DisplayServer.screen_get_size()
	if player_res == Vector2i(1920, 1080):
		res.selected = 0
	elif player_res == Vector2i(1600, 900):
		res.selected = 1
	elif player_res == Vector2i(1280, 720):
		res.selected = 2
	
	
func _process(delta):
	pass


func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)
	


func _on_mute_toggled(toggled_on):
	button_sound.play()
	AudioServer.set_bus_mute(0,toggled_on)
	
func _on_resolutions_item_selected(index):
	
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
			
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))
			
	centre_window()


func _on_back_button_pressed():
	button_sound.play()
	get_tree().change_scene_to_file("res://technical_scenes/start_menu.tscn")

func centre_window():
	var center_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(center_screen - window_size / 2)
	
func _on_window_modes_item_selected(index : int) -> void:
	match index:
		0: #полный экран
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		1: #оконный
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: #оконный без рамок
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: #полный с рамками
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			
func select_current_window_mode() -> void:
	var mode = DisplayServer.window_get_mode()
	var borderless = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	match mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			if borderless:
				window_button.select(3)
			else:
				window_button.select(0)
		DisplayServer.WINDOW_MODE_WINDOWED:
			if borderless:
				window_button.select(2)
			else:
				window_button.select(1)
		_:
			pass
