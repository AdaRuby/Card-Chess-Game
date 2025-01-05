extends Node2D

signal hovered
signal unhovered

var start_hand_position
var board : Array
var card_type : String
var card_side : String
var card_energy : int 

var queen_pos : Vector2

@onready var card_base: Sprite2D = $card_base
@onready var card_image: Sprite2D = $card_image
@onready var card_description: Label = $card_description
@onready var confirm_button: Button = $Confirm_chosen_piece
@onready var button_warning: Label = $Confirm_chosen_piece/button_warning
@onready var effect_label: Label = $effect_label
@onready var energy_label: Label = $energy_label
#@onready var card_slote_ref = $w_camera/w_cards/CardSlote

var collision_shape
var light_off_screen
var player_hand_w_ref
var player_hand_b_ref
var deck_w_ref
var deck_b_ref

func _ready() -> void:
	#ВСЕ карты должны быть частью card_manager, иначе выдаст ошибку.
	get_parent().connect_card_signals(self)
	collision_shape = $Area2D/CollisionShape2D
	light_off_screen = get_tree().get_first_node_in_group("light_off")
	player_hand_w_ref = get_tree().get_first_node_in_group("w_hand")
	player_hand_b_ref = get_tree().get_first_node_in_group("b_hand")
	deck_w_ref = get_tree().get_first_node_in_group("w_deck")
	deck_b_ref = get_tree().get_first_node_in_group("b_deck")

func use_card():
	get_board()
	print("card is used! look at the board now:")
	print(board)
	finish_card()

#1 функция для карты выключения света
func use_turn_off_light_card():
	#light_off_screen.visible = true
	#effect_label.global_position = Vector2(100, 100)
	#effect_label.text = "Ого! Как темно!"
	#effect_label.visible = true
	get_tree().get_first_node_in_group("main_scene").light_off_count_start()
	if card_side == "white":
		GameManadger.light_off_card_w = true
	if card_side == "black":
		GameManadger.light_off_card_b = true
	finish_card()

#1 функция для карты короля
func use_king_card():
	print("king card was used")
	finish_card()

#2 функции для карты королевы
func use_queen_card():
	GameManadger.queen_card = true
	get_board()
	if card_side == "white":
		queen_pos = find_piece_position(5)
	if card_side == "black":
		queen_pos = find_piece_position(-5)
	print("queen pos is ", queen_pos)
	confirm_button.visible = true
	confirm_button.global_position = Vector2(50, 300)
	hide_card()
	
func queen_card_finish():
	var selected_piece = GameManadger.piece_for_switching
	board[queen_pos.x][queen_pos.y] = board[selected_piece.x][selected_piece.y]
	if card_side == "white":
		board[selected_piece.x][selected_piece.y] = 5
	if card_side == "black":
		board[selected_piece.x][selected_piece.y] = -5
	GameManadger.get_board(board)
	GameManadger.piece_for_switching = Vector2(-1, -1)
	get_tree().get_first_node_in_group("main_scene").get_board()
	if card_side == "white":
		get_tree().get_first_node_in_group("main_scene").multiplayer_change_pos.rpc(queen_pos.y, queen_pos.x, selected_piece.x, selected_piece.y, 5)
	if card_side == "black":
		get_tree().get_first_node_in_group("main_scene").multiplayer_change_pos.rpc(queen_pos.y, queen_pos.x, selected_piece.x, selected_piece.y, -5)
	get_tree().get_first_node_in_group("main_scene").delete_dots()
	finish_card()

#карта сброса всех карт в руке и их замены
func discard_all():
	if card_side == "white":
		var w_hand_size = player_hand_w_ref.player_hand_w.size() - 1
		for card in player_hand_w_ref.player_hand_w:
			player_hand_w_ref.remove_card_from_hand(card)
			card.finish_card()
		while deck_w_ref.player_deck_w.size() > 0 and w_hand_size > 0:
			deck_w_ref.draw_card()
			w_hand_size -= 1
	
	if card_side == "black":
		var b_hand_size = player_hand_b_ref.player_hand_b.size() - 1
		for card in player_hand_b_ref.player_hand_b:
			player_hand_b_ref.remove_card_from_hand(card)
			card.finish_card()
		while deck_b_ref.player_deck_b.size() > 0 and b_hand_size > 0:
			deck_b_ref.draw_card()
			b_hand_size -= 1
	
	finish_card()


func find_piece_position(piece_id : int):
	for i in range(board.size()):
		for j in range(board.size()):
			if board[i][j] == piece_id:
				return Vector2(i,j)

func _on_area_2d_mouse_entered():
	emit_signal("hovered", self)

func finish_card():
	queue_free()

func _on_area_2d_mouse_exited():
	emit_signal("unhovered", self)

func get_board():
	board = GameManadger.board

func _on_confirm_chosen_piece_pressed():
	if GameManadger.piece_for_switching == Vector2(-1, -1):
		button_warning.visible = true
	else:
		queen_card_finish()
		GameManadger.queen_card = false
		confirm_button.visible = false

func hide_card():
	card_base.visible = false
	card_image.visible = false
	card_description.visible = false

func set_card_collision():
	if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
		if card_side == "white":
			collision_shape.disabled = false
		elif card_side == "black":
			collision_shape.disabled = true
	elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
		if card_side == "white":
			collision_shape.disabled = true
		if card_side == "black":
			collision_shape.disabled = false
		

func set_card_info(type):
	match type:
		"king_w":
				card_image.texture = GameManadger.king_w_image
				card_side = "white"
				card_description.text = GameManadger.king_desc
				card_energy = 1
				energy_label.text = str(card_energy)
		"king_b":
				card_image.texture = GameManadger.king_b_image
				card_side = "black"
				card_description.text = GameManadger.king_desc
				card_energy = 1
				energy_label.text = str(card_energy)
		"queen_w":
				card_image.texture = GameManadger.queen_w_image
				card_side = "white"
				card_description.text = GameManadger.queen_desc
				card_energy = 2
				energy_label.text = str(card_energy)
		"queen_b":
				card_image.texture = GameManadger.queen_b_image
				card_side = "black"
				card_description.text = GameManadger.queen_desc
				card_energy = 2
				energy_label.text = str(card_energy)
		"light_off_w":
			card_image.texture = GameManadger.light_off_card_image
			card_side = "white"
			card_description.text = GameManadger.light_off_card_desc
			card_energy = 1
			energy_label.text = str(card_energy)
		"light_off_b":
			card_image.texture = GameManadger.light_off_card_image
			card_side = "black"
			card_description.text = GameManadger.light_off_card_desc
			card_energy = 1
			energy_label.text = str(card_energy)
		"discard_all_w":
			card_side = "white"
			card_description.text = "Сбрасывает все карты в руке и берёт столько карт, сколько было сброшено"
			card_energy = 3
			energy_label.text = str(card_energy)
		"discard_all_b":
			card_side = "black"
			card_description.text = "Сбрасывает все карты в руке и берёт столько карт, сколько было сброшено"
			card_energy = 3
			energy_label.text = str(card_energy)
