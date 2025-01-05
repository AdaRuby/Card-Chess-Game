extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK = 1
const COLLISION_MASK_DECK = 4

var card_manager_ref_w
var card_manager_ref_b
var deck_ref_w
var deck_ref_b
var player_hand_ref_w 
var player_hand_ref_b 
var deck_label
@onready var hand_full_sound: AudioStreamPlayer = $"../sounds/hand_full_sound"

func _ready() -> void:
	card_manager_ref_w = $"../w_camera/w_cards/card_manager"
	card_manager_ref_b = $"../b_camera/b_cards/card_manager_b"
	deck_ref_w = $"../w_camera/w_cards/Deck"
	deck_ref_b = $"../b_camera/b_cards/Deck_b"
	player_hand_ref_w = $"../w_camera/w_cards/PlayerHand"
	player_hand_ref_b = $"../b_camera/b_cards/PlayerHand_b"
	deck_label = $"../deck_label"
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")

func raycast_at_cursor():
	var space = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	
	var result = space.intersect_point(params)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK:
			#карта кликнута.
			var card_found = result[0].collider.get_parent()
			if card_found:
				if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
					card_manager_ref_w.start_drag(card_found)
				elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
					card_manager_ref_b.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			#Дек кликнут.
			if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
				if check_for_full_hand_w():
					deck_label.text = "Максимум карт в руке!"
					hand_full_sound.play()
				else:
					deck_label.text = ""
					deck_ref_w.draw_card()
			elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
				if check_for_full_hand_b():
					deck_label.text = "Максимум карт в руке!"
					hand_full_sound.play()
				else:
					deck_label.text = ""
					deck_ref_b.draw_card()

func check_for_full_hand_w():
	if player_hand_ref_w.get_w_hand_size() > 3:
		return true
	else:
		return false

func check_for_full_hand_b():
	if player_hand_ref_b.get_b_hand_size() > 3:
		return true
	else:
		return false
