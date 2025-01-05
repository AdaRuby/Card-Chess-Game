extends Node2D

const COLLISION_MASK = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1

var is_hovering_on_card
var screen_size
var card_being_dragged
var player_hand_ref_w
var player_hand_ref_b
@onready var cant_play_sound: AudioStreamPlayer = $"../../../sounds/hand_full_sound"

#@onready var player_hand = load("res://cards/player_hand.tscn").instantiate()

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_ref_w = $"../../../w_camera/w_cards/PlayerHand"
	player_hand_ref_b = $"../../../b_camera/b_cards/PlayerHand_b"
	$"../../../InputManager".connect("left_mouse_button_released", on_left_click_released)
	
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x - 300, 0, screen_size.x),
		clamp(mouse_pos.y - 100, 0, screen_size.y))

#dont take drags, kids!
func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1, 1)
	
func end_drag():
	card_being_dragged.scale = Vector2(1.05, 1.05)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot and check_card_energy(card_being_dragged):
		if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
			player_hand_ref_w.remove_card_from_hand(card_being_dragged)
		elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
			player_hand_ref_b.remove_card_from_hand(card_being_dragged)
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
		#использование карты:
		if card_being_dragged.card_type == "king_w" or card_being_dragged.card_type == "king_b":
			card_being_dragged.use_king_card()
			card_slot_found.card_in_slot = false
		elif card_being_dragged.card_type == "queen_w" or card_being_dragged.card_type == "queen_b":
			card_being_dragged.use_queen_card()
			card_slot_found.card_in_slot = false
		elif card_being_dragged.card_type == "light_off_w":
			card_being_dragged.use_turn_off_light_card()
			card_slot_found.card_in_slot = false
			get_tree().get_first_node_in_group("main_scene").change_light_off_w.rpc()
		elif card_being_dragged.card_type == "light_off_b":
			card_being_dragged.use_turn_off_light_card()
			card_slot_found.card_in_slot = false
			get_tree().get_first_node_in_group("main_scene").change_light_off_b.rpc()
		elif card_being_dragged.card_type == "discard_all_w":
			card_being_dragged.discard_all()
			card_slot_found.card_in_slot = false
		elif card_being_dragged.card_type == "discard_all_b":
			card_being_dragged.discard_all()
			card_slot_found.card_in_slot = false
		else:
			card_being_dragged.use_card()
			card_slot_found.card_in_slot = false
		
		if card_being_dragged.card_side == "white":
			PlayerInfo.energy_white -= card_being_dragged.card_energy
		elif card_being_dragged.card_side == "black":
			PlayerInfo.energy_black -= card_being_dragged.card_energy
		get_tree().get_first_node_in_group("main_scene").update_labels()
	
	else:
		if (GameManadger.solo and GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_white):
			player_hand_ref_w.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
		elif (GameManadger.solo and !GameManadger.white) or (GameManadger.multi and PlayerInfo.chose_black):
			player_hand_ref_b.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
		cant_play_sound.play()
	card_being_dragged = null
	
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("unhovered", on_unhovered_over_card)
	
func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
func on_unhovered_over_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false
		
func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
	
func on_left_click_released():
	if card_being_dragged:
		end_drag()
	
func raycast_check_for_card_slot():
	var space = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space.intersect_point(params)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
		
func raycast_check_for_card():
	var space = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = COLLISION_MASK
	var result = space.intersect_point(params)
	if result.size() > 0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null
	
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
		
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
				
	return highest_z_card

func check_card_energy(card):
	if card.card_side == "white":
		if card.card_energy <= PlayerInfo.energy_white:
			return true
		else:
			return false
	elif card.card_side == "black":
		if card.card_energy <= PlayerInfo.energy_black:
			return true
		else:
			return false
