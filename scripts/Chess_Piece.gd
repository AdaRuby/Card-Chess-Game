class_name Chess_Piece

var piece_id : int
var piece_directions : Array = []

var white : bool = GameManadger.white
var board : Array = GameManadger.board
var white_king_position : Vector2 = GameManadger.white_king_position
var black_king_position : Vector2 = GameManadger.black_king_position
var en_passant = GameManadger.en_passant

var white_king : bool = GameManadger.white_king
var black_king : bool = GameManadger.black_king
var white_rook_left : bool = GameManadger.white_rook_left
var white_rook_right : bool = GameManadger.white_rook_right
var black_rook_left : bool = GameManadger.black_rook_left
var black_rook_right : bool = GameManadger.black_rook_right

func set_piece_id(id : int):
	piece_id = id

func set_directions(dir : Array):
	piece_directions = dir

func set_piece_id_and_directions(id : int, dir : Array):
	piece_id = id
	piece_directions = dir

func get_piece_moves(piece_position : Vector2, directions : Array):
	get_all_info(GameManadger.white, GameManadger.board, GameManadger.white_king_position,
	GameManadger.black_king_position, GameManadger.en_passant, GameManadger.white_king, 
	GameManadger.black_king, GameManadger.white_rook_left, GameManadger.white_rook_right,
	GameManadger.black_rook_left, GameManadger.black_rook_right)
	
	var _moves = []
	
	if piece_id == 1:
		var is_first_move = false
		var direction : Vector2
		if white: direction = Vector2(1, 0)
		else: direction = Vector2(-1, 0)
		
		if white && piece_position.x == 1 || !white && piece_position.x == 6: is_first_move = true
	
		if en_passant != null && (white && piece_position.x == 4 || !white && piece_position.x == 3) && abs(en_passant.y - piece_position.y) == 1:
			var pos = en_passant + direction
			board[pos.x][pos.y] = 1 if white else -1
			board[piece_position.x][piece_position.y] = 0
			board[en_passant.x][en_passant.y] = 0
			if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
			board[pos.x][pos.y] = 0
			board[piece_position.x][piece_position.y] =  1 if white else -1
			board[en_passant.x][en_passant.y] = -1 if white else 1
			
		var pos = piece_position + direction
		if is_empty(pos):
			board[pos.x][pos.y] = 1 if white else -1
			board[piece_position.x][piece_position.y] = 0
			if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
			board[pos.x][pos.y] = 0
			board[piece_position.x][piece_position.y] =  1 if white else -1
		
		pos = piece_position + Vector2(direction.x, 1)
		if is_valid_position(pos):
			if is_enemy(pos):
				var temp = board[pos.x][pos.y]
				board[pos.x][pos.y] = 1 if white else -1
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
				board[pos.x][pos.y] = temp
				board[piece_position.x][piece_position.y] =  1 if white else -1
		pos = piece_position + Vector2(direction.x, -1)
		if is_valid_position(pos):
			if is_enemy(pos):
				var temp = board[pos.x][pos.y]
				board[pos.x][pos.y] = 1 if white else -1
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
				board[pos.x][pos.y] = temp
				board[piece_position.x][piece_position.y] =  1 if white else -1
			
		pos = piece_position + direction * 2
		if is_first_move && is_empty(pos) && is_empty(piece_position + direction):
			board[pos.x][pos.y] = 1 if white else -1
			board[piece_position.x][piece_position.y] = 0
			if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
			board[pos.x][pos.y] = 0
			board[piece_position.x][piece_position.y] =  1 if white else -1
		
		
	elif piece_id == 6:
		if white:
			board[white_king_position.x][white_king_position.y] = 0
		else:
			board[black_king_position.x][black_king_position.y] = 0
			
		for i in directions:
			var pos = piece_position + i
			if is_valid_position(pos):
				if !is_in_check(pos):
					if is_empty(pos): _moves.append(pos)
					elif is_enemy(pos): 
						_moves.append(pos)
					
		if white && !white_king:
			if !white_rook_left && is_empty(Vector2(0, 1)) && is_empty(Vector2(0, 2)) && !is_in_check(Vector2(0, 2)) && is_empty(Vector2(0,3)) && !is_in_check(Vector2(0,3)) && !is_in_check(Vector2(0,4)): 
				_moves.append(Vector2(0,2))
			if !white_rook_right && !is_in_check(Vector2(0,4)) && is_empty(Vector2(0, 5)) && !is_in_check(Vector2(0,5)) && is_empty(Vector2(0, 6)) && !is_in_check(Vector2(0,6)): 
				_moves.append(Vector2(0,6))
				
		elif !white && !black_king:
			if !black_rook_left && is_empty(Vector2(7, 1)) && is_empty(Vector2(7, 2)) && !is_in_check(Vector2(7,2)) && is_empty(Vector2(7,3)) && !is_in_check(Vector2(7,3)) && !is_in_check(Vector2(7,4)): 
				_moves.append(Vector2(7,2))
			if !black_rook_right && !is_in_check(Vector2(7,4)) && is_empty(Vector2(7, 5)) && !is_in_check(Vector2(7,5)) && is_empty(Vector2(7, 6)) && !is_in_check(Vector2(7,6)): 
				_moves.append(Vector2(7,6))
					
		if white:
			board[white_king_position.x][white_king_position.y] = 6
		else:
			board[black_king_position.x][black_king_position.y] = -6
		
		
	elif piece_id == 2:
		for i in directions:
			var pos = piece_position + i
			if is_valid_position(pos):
				if is_empty(pos):
					board[pos.x][pos.y] = 2 if white else -2
					board[piece_position.x][piece_position.y] = 0
					if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
					board[pos.x][pos.y] = 0
					board[piece_position.x][piece_position.y] =  2 if white else -2
				elif is_enemy(pos):
					var temp = board[pos.x][pos.y]
					board[pos.x][pos.y] = 2 if white else -2
					board[piece_position.x][piece_position.y] = 0
					if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
					board[pos.x][pos.y] = temp
					board[piece_position.x][piece_position.y] =  2 if white else -2
		
	else:
		for i in directions:
			var pos = piece_position
			pos += i
			while is_valid_position(pos):
				if is_empty(pos):
					board[pos.x][pos.y] = piece_id if white else -piece_id
					board[piece_position.x][piece_position.y] = 0
					if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
					board[pos.x][pos.y] = 0
					board[piece_position.x][piece_position.y] =  piece_id if white else -piece_id
				elif is_enemy(pos):
					var temp = board[pos.x][pos.y]
					board[pos.x][pos.y] = piece_id if white else -piece_id
					board[piece_position.x][piece_position.y] = 0
					if white && !is_in_check(white_king_position) || !white && !is_in_check(black_king_position): _moves.append(pos)
					board[pos.x][pos.y] = temp
					board[piece_position.x][piece_position.y] =  piece_id if white else -piece_id
					break
				else: break
				
				pos += i
	
	return _moves


func is_valid_position(pos:Vector2):
	if pos.x >= 0 && pos.x < GameManadger.BOARD_SIZE && pos.y >= 0 && pos.y < GameManadger.BOARD_SIZE: return true
	return false

func is_empty(pos : Vector2):
	if board[pos.x][pos.y] == 0: return true
	return false

func is_enemy(pos : Vector2):
	if white && board[pos.x][pos.y] < 0 || !white && board[pos.x][pos.y] > 0: return true
	return false

func is_in_check(king_pos : Vector2):
	var directions = [Vector2(0,1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	Vector2(1,1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	var pawn_direction = 1 if white else -1
	var pawn_attack = [
		king_pos + Vector2(pawn_direction, 1),
		king_pos + Vector2(pawn_direction, -1)
	]
	
	for i in pawn_attack:
		if is_valid_position(i):
			if (white && board[i.x][i.y] == -1 || !white && board[i.x][i.y] == 1): return true
			
	for i in directions:
		var pos = king_pos + i
		if is_valid_position(pos):
			if white && board[pos.x][pos.y] == -6 || !white && board[pos.x][pos.y] == 6: return true
			
	for i in directions:
		var pos = king_pos + i
		while is_valid_position(pos):
			if !is_empty(pos):
				var piece = board[pos.x][pos.y] 
				if (i.x == 0 || i.y == 0) && (white && piece in [-4, -5] || !white && piece in [4, 5]):
					return true
				elif (i.x != 0 && i.y != 0) && (white && piece in [-3, -5] || !white && piece in [3, 5]):
					return true
				break
			pos += i 
			
	var knight_directions = [Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(-1, 2),
	Vector2(-2, 1), Vector2(-2, -1), Vector2(1, -2), Vector2(-1, -2)]
	
	for i in knight_directions: 
		var pos = king_pos + i
		if is_valid_position(pos):
			if white && board[pos.x][pos.y] == -2 || !white && board[pos.x][pos.y] == 2:
				return true
				
	return false

func get_all_info(w : bool, b : Array, wkp : Vector2, bkp : Vector2, ep, wk : bool,
bk : bool, wrl : bool, wrr : bool, brl : bool, brr : bool):
	white = w
	board = b
	white_king_position = wkp
	black_king_position = bkp
	en_passant = ep
	white_king = wk
	black_king = bk
	white_rook_left = wrl
	white_rook_right = wrr
	black_rook_left = brl
	black_rook_right = brr
