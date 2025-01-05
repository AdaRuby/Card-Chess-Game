extends Node3D

const BOARD_SIZE = 8
const CELL_WIDTH = 1
const DISTANCE = 1000

var mouse = Vector2()
var row : int
var column : int
var piece_clicked : bool

var promotion_square = null
var en_passant = null

const TEXTURE_HOLDER = preload("res://technical_scenes/texture_holder.tscn")
const PIECE_MOVE = preload("res://models/meshes/a_move.tres")
const WHITE_PAWN = preload("res://pieces/pawn_w.tscn")
const WHITE_BISHOP = preload("res://pieces/bishop_w.tscn")
const WHITE_KING = preload("res://pieces/king_w.tscn")
const WHITE_KNIGHT = preload("res://pieces/knight_w.tscn")
const WHITE_QUEEN = preload("res://pieces/queen_w.tscn")
const WHITE_ROOK = preload("res://pieces/rook_w.tscn")
const BLACK_PAWN = preload("res://pieces/pawn_b.tscn")
const BLACK_BISHOP = preload("res://pieces/bishop_b.tscn")
const BLACK_KING = preload("res://pieces/king_b.tscn")
const BLACK_KNIGHT = preload("res://pieces/knight_b.tscn")
const BLACK_QUEEN = preload("res://pieces/queen_b.tscn")
const BLACK_ROOK = preload("res://pieces/rook_b.tscn")

@onready var pieces: Node3D = $pieces
@onready var dots = $dots
@onready var w_camera: Camera3D = $w_camera
@onready var b_camera: Camera3D = $b_camera
#@onready var turn =  
@onready var white_pieces: Control = $w_camera/promotion_buttons/white_pieces
@onready var black_pieces: Control = $b_camera/promotion_buttons/black_pieces
@onready var w_cards: Control = $w_camera/w_cards
@onready var b_cards: Control = $b_camera/b_cards
@onready var piece_move_sound: AudioStreamPlayer = $sounds/piece_move_sound
#@onready var environment: WorldEnvironment = $WorldEnvironment
@onready var side_count: Label = $labels/side_count
@onready var side_label: Label = $labels/side_label
@onready var effect_label: Label = $labels/effect_label
@onready var light_off: ColorRect = $effects/light_off
@onready var deck_label: Label = $deck_label
@onready var energy_label: Label = $energy/energy_label
@onready var final_text: Label = $final_screen/final_text
@onready var final_screen: Control = $final_screen
@onready var final_button: Button = $final_screen/final_button
@onready var button_sound: AudioStreamPlayer = $sounds/button_sound

@onready var pawn = Chess_Piece.new()
@onready var knight = Chess_Piece.new()
@onready var bishop = Chess_Piece.new()
@onready var rook = Chess_Piece.new()
@onready var queen = Chess_Piece.new()
@onready var king = Chess_Piece.new()

var board : Array
var white : bool = PlayerInfo.chose_white
var state : bool = false
var side_change_count : int = 1
var light_off_count : int

var white_king : bool = false
var black_king : bool = false
var white_rook_left : bool = false
var white_rook_right : bool = false
var black_rook_left : bool = false
var black_rook_right : bool = false

var moves = []
var selected_piece : Vector2
var white_king_position : Vector2 = Vector2(0, 4)
var black_king_position : Vector2 = Vector2(7, 4)
var piece_for_switching : Vector2

func _ready():
	#get_viewport().size = DisplayServer.screen_get_size()
	
	board.append([4, 2, 3, 5, 6, 3, 2, 4])
	board.append([1, 1, 1, 1, 1, 1, 1, 1]) #pawns
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])
	
	display_board()
	
	pawn.set_piece_id_and_directions(GameManadger.pawn_id, GameManadger.pawn_dir)
	knight.set_piece_id_and_directions(GameManadger.knight_id, GameManadger.knight_dir)
	bishop.set_piece_id_and_directions(GameManadger.bishop_id, GameManadger.bishop_dir)
	rook.set_piece_id_and_directions(GameManadger.rook_id, GameManadger.rook_dir)
	queen.set_piece_id_and_directions(GameManadger.queen_id, GameManadger.queen_dir)
	king.set_piece_id_and_directions(GameManadger.king_id, GameManadger.king_dir)
	
	var promotion_w_buttons = get_tree().get_nodes_in_group("white_pieces")
	var promotion_b_buttons = get_tree().get_nodes_in_group("black_pieces")
	
	for button in promotion_w_buttons:
		button.pressed.connect(self._on_promotion_button_pressed.bind(button))
	
	for button in promotion_b_buttons:
		button.pressed.connect(self._on_promotion_button_pressed.bind(button))
	
	update_labels()
	#if get_global_mouse_position().x < 0 || get_global_mouse_position().x > 800 || get_global_mouse_position().y > 0 || get_global_mouse_position().y < -800: return true
	#return false

func display_board():
	for child in pieces.get_children():
		child.queue_free()
		
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()
			var king_b = BLACK_KING.instantiate()
			var king_w = WHITE_KING.instantiate()
			var queen_b = BLACK_QUEEN.instantiate()
			var queen_w = WHITE_QUEEN.instantiate()
			var bishop_b = BLACK_BISHOP.instantiate()
			var bishop_w = WHITE_BISHOP.instantiate()
			var knight_b = BLACK_KNIGHT.instantiate()
			var knight_w = WHITE_KNIGHT.instantiate()
			var rook_b = BLACK_ROOK.instantiate()
			var rook_w = WHITE_ROOK.instantiate()
			var pawn_b = BLACK_PAWN.instantiate()
			var pawn_w = WHITE_PAWN.instantiate()
			pieces.add_child(holder)
			#holder.global_position = Vector3(j * CELL_WIDTH + (CELL_WIDTH / 2), 0, -i * CELL_WIDTH - (CELL_WIDTH / 2))
			holder.global_position = Vector3(j * CELL_WIDTH + 0.5, 0.5, -i * CELL_WIDTH - 0.5)
			
			match board[i][j]:
				-6: holder.add_child(king_b)
				-5: holder.add_child(queen_b)
				-4: holder.add_child(rook_b)
				-3: holder.add_child(bishop_b)
				-2: holder.add_child(knight_b)
				-1: holder.add_child(pawn_b)
				#0: holder.add_child(null)
				6: holder.add_child(king_w)
				5: holder.add_child(queen_w)
				4: holder.add_child(rook_w)
				3: holder.add_child(bishop_w)
				2: holder.add_child(knight_w)
				1: holder.add_child(pawn_w)
	
	get_info_to_manager()
	
	if GameManadger.solo:
		setup_camera()
		if white: 
			w_cards.visible = true
			b_cards.visible = false
		else:
			w_cards.visible = false
			b_cards.visible = true
	if GameManadger.multi:
		if white and PlayerInfo.chose_white:
			w_cards.visible = true
			b_cards.visible = false
		else:
			w_cards.visible = false
		if !white and !PlayerInfo.chose_white:
			w_cards.visible = false
			b_cards.visible = true
		else:
			b_cards.visible = false
	
	if get_tree().get_node_count_in_group("card") > 0:
		var cards = get_tree().get_nodes_in_group("card")
		for card in cards:
			card.set_card_collision()
	
	handle_light_off()

func _input(event):
	if GameManadger.solo or (GameManadger.multi and ((PlayerInfo.chose_white && white) or (!PlayerInfo.chose_white && !white))):
		if event is InputEventMouseMotion:
			mouse = event.position
		if event is InputEventMouseButton && promotion_square == null:
			if event.pressed == false && event.button_index == MOUSE_BUTTON_LEFT:
				get_mouse_world_pos(mouse)
				print(column, row)
				if GameManadger.queen_card and (white && board[column][row] > 0 || !white && board[column][row] < 0) and piece_clicked:
					delete_dots()
					piece_for_switching = Vector2(column, row)
					GameManadger.get_piece_for_switching(piece_for_switching)
					show_selection(piece_for_switching)
				elif !state && (white && board[column][row] > 0 || !white && board[column][row] < 0):
					selected_piece = Vector2(column, row)
					show_options()
					state = true
				elif state: set_move(column, row)
			

func get_mouse_world_pos(mouse:Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, DISTANCE)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	
	var result = space.intersect_ray(params)
	if !result.is_empty():
		row = int(result['position'].x)
		column = -int(result['position'].z)
		piece_clicked = true
	else:
		row = -1
		column = -1
		piece_clicked = false

func show_options():
	moves = get_moves(selected_piece)
	print(moves)
	if moves == []:
		state = false
		return
	show_dots()
	
func show_dots():
	var dots_count : int = 0
	for i in moves:
		dots_count += 1
		var holder = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.mesh = PIECE_MOVE
		holder.global_position = Vector3(i.y + 0.5, 0.5, -i.x - 0.5)
	
func delete_dots():
	for child in dots.get_children():
		child.queue_free()
		

func show_selection(piece):
		var holder = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.mesh = PIECE_MOVE
		holder.global_position = Vector3(piece.y + 0.5, 0.5, -piece.x - 0.5)

func set_move(var2, var1):
	var just_now = false
	for i in moves:
		if i.x == var2 && i.y == var1:
			match board[selected_piece.x][selected_piece.y]:
				1:
					if i.x == 7: promote(i)
					if i.x == 3 && selected_piece.x == 1:
						en_passant = i
						just_now = true
					elif en_passant != null:
						if en_passant.y == i.y && selected_piece.y != i.y && en_passant.x == selected_piece.x:
							board[en_passant.x][en_passant.y] = 0
				-1: 
					if i.x == 0: promote(i)
					if i.x == 4 && selected_piece.x == 6:
						en_passant = i
						just_now = true
					elif en_passant != null:
						if en_passant.y == i.y && selected_piece.y != i.y && en_passant.x == selected_piece.x:
							board[en_passant.x][en_passant.y] = 0
				4:
					if selected_piece.x == 0 && selected_piece.y == 0: white_rook_left = true
					elif selected_piece.x == 0 && selected_piece.y == 7: white_rook_right = true
				-4:
					if selected_piece.x == 7 && selected_piece.y == 0: black_rook_left = true
					elif selected_piece.x == 7 && selected_piece.y == 7: black_rook_right = true
				6: 
					if selected_piece.x == 0 && selected_piece.y == 4:
						white_king = true
						if i.y == 2:
							white_rook_left = true
							white_rook_right = true
							board[0][0] = 0 
							board[0][3] = 4
						elif i.y == 6: 
							white_rook_left = true
							white_rook_right = true
							board[0][7] = 0 
							board[0][5] = 4
					white_king_position = i
				-6:
					if selected_piece.x == 7 && selected_piece.y == 4:
						black_king = true
						if i.y == 2:
							black_rook_left = true
							black_rook_right = true
							board[7][0] = 0 
							board[7][3] = -4
						elif i.y == 6: 
							black_rook_left = true
							black_rook_right = true
							board[7][7] = 0 
							board[7][5] = -4
					black_king_position = i
			if !just_now: en_passant = null
			board[var2][var1] = board[selected_piece.x][selected_piece.y]
			board[selected_piece.x][selected_piece.y] = 0
			white = !white
			add_energy()
			side_change_count += 1
			light_off_count_change()
			update_labels()
			change_side.rpc()
			display_board()
			multiplayer_change_pos.rpc(var1, var2, selected_piece.x, selected_piece.y, 0)
			piece_move_sound.play()
			break
	delete_dots()
	state = false
	
	check_for_stalemate()
	check_for_stalemate.rpc()

@rpc("any_peer")
func multiplayer_change_pos(new1, new2, old1, old2, piece):
	board[new2][new1] = board[old1][old2]
	board[old1][old2] = piece
	display_board()

func get_moves(selected : Vector2):
	var _moves
	match abs(board[selected.x][selected.y]):
		1: _moves = pawn.get_piece_moves(selected, pawn.piece_directions)
		2: _moves = knight.get_piece_moves(selected, knight.piece_directions)
		3: _moves = bishop.get_piece_moves(selected, bishop.piece_directions)
		4: _moves = rook.get_piece_moves(selected, rook.piece_directions)
		5: _moves = queen.get_piece_moves(selected, queen.piece_directions)
		6: _moves = king.get_piece_moves(selected, king.piece_directions)
	
	return _moves
	

func promote(_var : Vector2):
	promotion_square = _var
	white_pieces.visible = white
	black_pieces.visible = !white
	
func _on_promotion_button_pressed(button):
	var new_piece = int(button.name.substr(0, 1))
	board[promotion_square.x][promotion_square.y] = -new_piece if white else new_piece
	multiplayer_promotion.rpc(promotion_square.x, promotion_square.y, new_piece)
	white_pieces.visible = false
	black_pieces.visible = false
	promotion_square = null
	display_board()

@rpc("any_peer")
func multiplayer_promotion(square1, square2, new):
	board[square1][square2] = -new if white else new
	display_board()

func setup_camera():
	if white: w_camera.current = true
	else: b_camera.current = true

func setup_multiplayer_camera():
	if PlayerInfo.Players.has("side"):
		if PlayerInfo.Players["side"] == "white": w_camera.current = true
		elif PlayerInfo.Players["side"] == "black": b_camera.current = true

func show_cards():
	w_cards.visible = true
	
func hide_cards():
	w_cards.visible = false

@rpc("any_peer")
func change_side():
	white = !white
	side_change_count += 1
	light_off_count_change()
	get_info_to_manager()
	update_labels()
	add_energy()

@rpc("any_peer")
func get_board():
	board = GameManadger.board
	display_board()

func update_labels():
	side_count.text = "Номер раунда: " + str(side_change_count)
	
	if white:
		side_label.text = "Сейчас ходит: белая сторона"
	else:
		side_label.text = "Сейчас ходит: чёрная сторона"
	
	if GameManadger.light_off_card_w or GameManadger.light_off_card_b:
		effect_label.text = "Ходов до включения света: " + str(light_off_count)
	else:
		effect_label.text = ""
	
	deck_label.text = ""
	
	update_energy_label()

func light_off_count_start():
	light_off_count = 3

func light_off_count_change():
	if GameManadger.light_off_card_w or GameManadger.light_off_card_b:
		light_off_count -= 1

@rpc("any_peer")
func handle_light_off():
	if light_off_count > 0:
		if GameManadger.solo:
			if white and GameManadger.light_off_card_b:
				light_off.visible = true
			elif !white and GameManadger.light_off_card_w:
				light_off.visible = true
			else:
				light_off.visible = false
		if GameManadger.multi:
			if PlayerInfo.chose_white and GameManadger.light_off_card_b:
				light_off.visible = true
			elif PlayerInfo.chose_black and GameManadger.light_off_card_w:
				light_off.visible = true
			else:
				light_off.visible = false
	else:
		light_off.visible = false
	
	if light_off_count == 0 and (GameManadger.light_off_card_w or GameManadger.light_off_card_b):
		GameManadger.light_off_card_w = false
		GameManadger.light_off_card_b = false
	
	update_labels()

@rpc("any_peer")
func change_light_off_w():
	GameManadger.light_off_card_w = true
	light_off_count_start()
	handle_light_off()
@rpc("any_peer")
func change_light_off_b():
	GameManadger.light_off_card_b = true
	light_off_count_start()
	handle_light_off()

func get_info_to_manager():
	GameManadger.get_all_info(white, board, white_king_position, black_king_position,
	en_passant, white_king, black_king, white_rook_left, white_rook_right,
	black_rook_left, black_rook_right, side_change_count, light_off_count)

func add_energy():
	if GameManadger.solo:
		if white:
			PlayerInfo.energy_white += 2
			if PlayerInfo.energy_white > 4:
				PlayerInfo.energy_white = 4
			update_energy_label()
		elif !white:
			PlayerInfo.energy_black += 2
			if PlayerInfo.energy_black > 4:
				PlayerInfo.energy_black = 4
			update_energy_label()
	if GameManadger.multi:
		if PlayerInfo.chose_white and white:
			PlayerInfo.energy_white += 2
			if PlayerInfo.energy_white > 4:
				PlayerInfo.energy_white = 4
			update_energy_label()
		elif PlayerInfo.chose_black and !white:
			PlayerInfo.energy_black += 2
			if PlayerInfo.energy_black > 4:
				PlayerInfo.energy_black = 4
			update_energy_label()

func update_energy_label():
	if GameManadger.solo:
		if white:
			energy_label.text = str(PlayerInfo.energy_white) + "/4"
		elif !white:
			energy_label.text = str(PlayerInfo.energy_black) + "/4"
	if GameManadger.multi:
		if PlayerInfo.chose_white:
			energy_label.text = str(PlayerInfo.energy_white) + "/4"
		elif PlayerInfo.chose_black:
			energy_label.text = str(PlayerInfo.energy_black) + "/4"

func is_stalemate():
	if white:
		for i in BOARD_SIZE:
			for j in BOARD_SIZE:
				if board[i][j] > 0:
					if get_moves(Vector2(i,j)) != []: return false
	else:
		for i in BOARD_SIZE:
			for j in BOARD_SIZE:
				if board[i][j] < 0:
					if get_moves(Vector2(i,j)) != []: return false
	return true

func _on_final_button_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://technical_scenes/start_menu.tscn")

@rpc("any_peer")
func check_for_stalemate():
	if is_stalemate():
		if white && king.is_in_check(white_king_position):
			final_screen.visible = true
			final_text.text = "Шах и мат!\nЧёрная сторона победила!"
		elif !white && king.is_in_check(black_king_position):
			final_screen.visible = true
			final_text.text = "Шах и мат!\nБелая сторона победила!"
		else: 
			final_screen.visible = true
			final_text.text = "Ничья."
