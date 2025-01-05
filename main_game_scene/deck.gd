extends Node2D

const CARD_SCENE_PATH = "res://cards/card.tscn"
const CARD_DRAW_SPEED = 0.5

@onready var draw_card_sound: AudioStreamPlayer = $"../../../sounds/draw_card_sound"
var card_manager_ref_w 
var card_manager_ref_b 
var player_hand_ref_w 
var player_hand_ref_b 
var side_ref
var deck_w_ref
var deck_b_ref

var player_deck_w : Array = []
var player_deck_b : Array = []
var deck_database_ref

func _ready():
	deck_database_ref = preload("res://cards/DecksDatabase.gd")
	
	character_choice()
	#player_deck_w.append_array(deck_database_ref.w_cards)
	player_deck_w.shuffle()
	
	#player_deck_b.append_array(deck_database_ref.b_cards)
	player_deck_b.shuffle()
	
	side_ref = get_parent()
	if side_ref.name == "w_cards":
		#$Area2D_b/CollisionShape2D.disabled = true
		$Area2D_w/CollisionPolygon2D.disabled = true
		$Sprite2D_b.visible = false
	elif side_ref.name == "b_cards":
		#$Area2D_w/CollisionShape2D.disabled = true
		$Area2D_b/CollisionPolygon2D.disabled = true
		$Sprite2D_w.visible = false
	card_manager_ref_w = $"../../../w_camera/w_cards/card_manager"
	card_manager_ref_b = $"../../../b_camera/b_cards/card_manager_b"
	player_hand_ref_w = $"../../../w_camera/w_cards/PlayerHand"
	player_hand_ref_b = $"../../../b_camera/b_cards/PlayerHand_b"
	deck_w_ref = $"../../../decks/deck_w"
	deck_b_ref = $"../../../decks/deck_b"

func character_choice():
	#соло проверка (работает, пока нельзя выбрать двух разных персонажей, потом нужно будет изменить)
	if GameManadger.solo:
		if PlayerInfo.chosen_character == 1:
			player_deck_w.append_array(deck_database_ref.w_knight_deck)
			player_deck_w.append_array(deck_database_ref.w_cards)
			player_deck_b.append_array(deck_database_ref.b_knight_deck)
			player_deck_b.append_array(deck_database_ref.b_cards)
		elif PlayerInfo.chosen_character == 2:
			player_deck_w.append_array(deck_database_ref.w_bishop_deck)
			player_deck_w.append_array(deck_database_ref.w_cards)
			player_deck_b.append_array(deck_database_ref.b_bishop_deck)
			player_deck_b.append_array(deck_database_ref.b_cards)
		elif PlayerInfo.chosen_character == 3:
			player_deck_w.append_array(deck_database_ref.w_rook_deck)
			player_deck_w.append_array(deck_database_ref.w_cards)
			player_deck_b.append_array(deck_database_ref.b_rook_deck)
			player_deck_b.append_array(deck_database_ref.b_cards)
		elif PlayerInfo.chosen_character == 4:
			player_deck_w.append_array(deck_database_ref.w_queen_deck)
			player_deck_w.append_array(deck_database_ref.w_cards)
			player_deck_b.append_array(deck_database_ref.b_queen_deck)
			player_deck_b.append_array(deck_database_ref.b_cards)
		elif PlayerInfo.chosen_character == 5:
			player_deck_w.append_array(deck_database_ref.w_king_deck)
			player_deck_w.append_array(deck_database_ref.w_cards)
			player_deck_b.append_array(deck_database_ref.b_king_deck)
			player_deck_b.append_array(deck_database_ref.b_cards)
	#мультиплеерная проверка (работает шикарно)
	if PlayerInfo.chosen_character == 1 and (GameManadger.multi and PlayerInfo.chose_white):
		player_deck_w.append_array(deck_database_ref.w_knight_deck)
		player_deck_w.append_array(deck_database_ref.w_cards)
	elif PlayerInfo.chosen_character == 1 and (GameManadger.multi and PlayerInfo.chose_black):
		player_deck_b.append_array(deck_database_ref.b_knight_deck)
		player_deck_b.append_array(deck_database_ref.b_cards)
	elif PlayerInfo.chosen_character == 2 and(GameManadger.multi and PlayerInfo.chose_white):
		player_deck_w.append_array(deck_database_ref.w_bishop_deck)
		player_deck_w.append_array(deck_database_ref.w_cards)
	elif PlayerInfo.chosen_character == 2 and(GameManadger.multi and PlayerInfo.chose_black):
		player_deck_b.append_array(deck_database_ref.b_bishop_deck)
		player_deck_b.append_array(deck_database_ref.b_cards)
	elif PlayerInfo.chosen_character == 3 and (GameManadger.multi and PlayerInfo.chose_white):
		player_deck_w.append_array(deck_database_ref.w_rook_deck)
		player_deck_w.append_array(deck_database_ref.w_cards)
	elif PlayerInfo.chosen_character == 3 and (GameManadger.multi and PlayerInfo.chose_black):
		player_deck_b.append_array(deck_database_ref.b_rook_deck)
		player_deck_b.append_array(deck_database_ref.b_cards)
	elif PlayerInfo.chosen_character == 4 and (GameManadger.multi and PlayerInfo.chose_white):
		player_deck_w.append_array(deck_database_ref.w_queen_deck)
		player_deck_w.append_array(deck_database_ref.w_cards)
	elif PlayerInfo.chosen_character == 4 and (GameManadger.multi and PlayerInfo.chose_black):
		player_deck_b.append_array(deck_database_ref.b_queen_deck)
		player_deck_b.append_array(deck_database_ref.b_cards)
	elif PlayerInfo.chosen_character == 5 and (GameManadger.multi and PlayerInfo.chose_white):
		player_deck_w.append_array(deck_database_ref.w_king_deck)
		player_deck_w.append_array(deck_database_ref.w_cards)
	elif PlayerInfo.chosen_character == 5 and (GameManadger.multi and PlayerInfo.chose_black):
		player_deck_b.append_array(deck_database_ref.b_king_deck)
		player_deck_b.append_array(deck_database_ref.b_cards)
	
	#для тестов
	if PlayerInfo.chosen_character == 0:
		player_deck_w.append_array(deck_database_ref.w_cards)
		player_deck_b.append_array(deck_database_ref.b_cards)


func draw_card():
	var card_draw
	if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
		if player_deck_w.size() == 0:
			#$Area2D_w/CollisionShape2D.disabled = true
			$Area2D_w/CollisionPolygon2D.disabled = true
			$Sprite2D_w.visible = false
			return
		
		card_draw = get_card_from_deck(player_deck_w)
		
	elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
		if player_deck_b.size() == 0:
			#$Area2D_b/CollisionShape2D.disabled = true
			$Area2D_b/CollisionPolygon2D.disabled = true
			$Sprite2D_b.visible = false
			return
		
		card_draw = get_card_from_deck(player_deck_b)
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
		card_manager_ref_w.add_child(new_card)
	elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
		card_manager_ref_b.add_child(new_card)
	new_card.name = card_draw
	new_card.card_type = card_draw
	new_card.set_card_info(card_draw)
	if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
		player_hand_ref_w.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
		player_hand_ref_b.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	
	check_for_empty_deck()
	draw_card_sound.play()
	deck_w_ref.update_deck_size()
	deck_b_ref.update_deck_size()
	print(player_deck_w)

func get_card_from_deck(player_deck):
	var card_draw = player_deck[0]
	player_deck.erase(card_draw)
	
	return card_draw

func check_for_empty_deck():
	if player_deck_w.size() == 0:
		#$Area2D_w/CollisionShape2D.disabled = true
		$Area2D_w/CollisionPolygon2D.disabled = true
		$Sprite2D_w.visible = false
	elif player_deck_b.size() == 0:
		#$Area2D_b/CollisionShape2D.disabled = true
		$Area2D_b/CollisionPolygon2D.disabled = true
		$Sprite2D_b.visible = false

func get_w_deck_size():
	return player_deck_w.size()

func get_b_deck_size():
	return player_deck_b.size()
