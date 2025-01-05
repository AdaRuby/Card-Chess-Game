extends Node2D

const CARD_WIDTH = 200
const HAND_Y_POSITION = 750
const DEFAULT_CARD_MOVE_SPEED = 0.1

var player_hand_w = []
var player_hand_b = []
var center_screen_x

func _ready():
	
	center_screen_x = get_viewport().size.x/2

	
func add_card_to_hand(card, speed):
	if card.card_side == "white":
		if card not in player_hand_w:
			player_hand_w.insert(0, card)
			update_hand_positions(speed)
		else:
			animate_card_to_position(card, card.start_hand_position, DEFAULT_CARD_MOVE_SPEED)
	if card.card_side == "black":
		if card not in player_hand_b:
			player_hand_b.insert(0, card)
			update_hand_positions(speed)
		else:
			animate_card_to_position(card, card.start_hand_position, DEFAULT_CARD_MOVE_SPEED)
		
func update_hand_positions(speed):
	if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
		for i in range (player_hand_w.size()):
			var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
			var card = player_hand_w[i]
			card.start_hand_position = new_position
			animate_card_to_position(card, new_position, speed)
	elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
		for i in range (player_hand_b.size()):
			var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
			var card = player_hand_b[i]
			card.start_hand_position = new_position
			animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(index):
	if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
		var total_width = (player_hand_w.size() -1) * CARD_WIDTH
		var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
		return x_offset
	elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
		var total_width = (player_hand_b.size() -1) * CARD_WIDTH
		var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
		return x_offset
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card.card_side == "white":
		if card in player_hand_w:
			player_hand_w.erase(card)
			update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
	if card.card_side == "black":
		if card in player_hand_b:
			player_hand_b.erase(card)
			update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
	
func get_w_hand_size():
	return player_hand_w.size()

func get_b_hand_size():
	return player_hand_b.size()
