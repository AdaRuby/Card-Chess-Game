extends Control

#1 - конь, 2 - слон, 3 - ладья, 4 - ферзь, 5 - король.
var character_id = 1

@onready var sprite_ref = $Character
@onready var name_ref = $name
@onready var desc_ref = $description
@onready var game_scene = preload("res://main_game_scene/main_game_screen.tscn").instantiate()

func _ready():
	#var deck_database_ref = preload("res://cards/DecksDatabase.gd")
	sprite_ref.texture = preload("res://assets/sprites/smoke_7.png")
	name_ref.text = "Конь."
	desc_ref.text = "Сочетает в себе как большой атакующий потенциал, так и защитный. Средняя фигура."
	
func change_character():
	match character_id:
		1:
			sprite_ref.texture = preload("res://assets/sprites/smoke_7.png")
			name_ref.text = "Конь."
			desc_ref.text = "Сочетает в себе как большой атакующий потенциал, так и защитный. Средняя фигура."
		2:
			sprite_ref.texture = preload("res://assets/sprites/frame.png")
			name_ref.text = "Чернопольный и Белопольный слон. Трикстер."
			desc_ref.text = "Огромные проказники."
		3:
			sprite_ref.texture = preload("res://assets/sprites/ladia.png")
			name_ref.text = "Ладья. Защитница."
			desc_ref.text = "Способна долгое время держать оборону."
		4:
			sprite_ref.texture = preload("res://assets/sprites/return_hover.png")
			name_ref.text = "Ферзь. Убийца."
			desc_ref.text = "Хорошо атакует, но не может защищаться. Огромный риск - большая награда."
		5:
			sprite_ref.texture = preload("res://assets/sprites/fire_35.png")
			name_ref.text = "Король. Он король."
			desc_ref.text = "Отдает приказы и обладает капризным нравом."


func _on_next_pressed():
	if character_id < 5:
		character_id += 1
	change_character()


func _on_back_pressed():
	if character_id > 1:
		character_id -= 1
	change_character()


func _on_choice_pressed():
	match character_id:
		1:
			PlayerInfo.chosen_character = character_id
		2:
			PlayerInfo.chosen_character = character_id
		3:
			PlayerInfo.chosen_character = character_id
		4:
			PlayerInfo.chosen_character = character_id
		5:
			PlayerInfo.chosen_character = character_id
	get_tree().root.add_child(game_scene)
	if GameManadger.multi:
		game_scene.setup_multiplayer_camera()
		if PlayerInfo.chose_white:
			game_scene.show_cards()
	self.hide()
