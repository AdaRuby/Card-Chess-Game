extends Node

const BOARD_SIZE : int = 8

var solo : bool = true
var multi : bool = false

#информация о фигурах
var pawn_id : int = 1
var pawn_dir : Array = []

var knight_id : int = 2
var knight_dir : Array = [Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(-1, 2),
	Vector2(-2, 1), Vector2(-2, -1), Vector2(1, -2), Vector2(-1, -2)]

var bishop_id : int = 3
var bishop_dir : Array = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

var rook_id : int = 4
var rook_dir : Array = [Vector2(0,1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]

var queen_id : int = 5
var queen_dir : Array = [Vector2(0,1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	Vector2(1,1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

var king_id : int = 6
var king_dir : Array = [Vector2(0,1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	Vector2(1,1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

#информация из основного скрипта шахмат
var white : bool 
var board : Array 
var white_king_position : Vector2 
var black_king_position : Vector2 
var en_passant 
var white_king : bool 
var black_king : bool 
var white_rook_left : bool 
var white_rook_right : bool 
var black_rook_left : bool 
var black_rook_right : bool 
var side_change_count : int
var light_off_count : int

var piece_for_switching : Vector2 = Vector2(-1, -1)

#информация о картах
var king_w_image = preload("res://models/sprites/chess_sprites_w_king.png")
var king_b_image = preload("res://models/sprites/chess_sprites_b_king.png")
var king_desc = "This is a king card"

var queen_w_image = preload("res://models/sprites/chess_sprites_w_queen.png")
var queen_b_image = preload("res://models/sprites/chess_sprites_b_queen.png")
var queen_desc = "This is a queen card"
var queen_card : bool = false

var rook_w_image = preload("res://models/sprites/chess_sprites_w_rook.png")
var rook_b_image = preload("res://models/sprites/chess_sprites_b_rook.png")
var rook_desc = "This is a rook card"

var bishop_w_image = preload("res://models/sprites/chess_sprites_w_bishop.png")
var bishop_b_image = preload("res://models/sprites/chess_sprites_b_bishop.png")
var bishop_desc = "This is a bishop card"

var knight_w_image = preload("res://models/sprites/chess_sprites_w_knight.png")
var knight_b_image = preload("res://models/sprites/chess_sprites_b_knight.png")
var knight_desc = "This is a knight card"

var pawn_w_image = preload("res://models/sprites/chess_sprites_w_pawn.png")
var pawn_b_image = preload("res://models/sprites/chess_sprites_b_pawn.png")
var pawn_desc = "This is a pawn card"

var light_off_card_image 
var light_off_card_desc = "This card turns of light for the opponent"
var light_off_card_w : bool = false
var light_off_card_b : bool = false



func get_all_info(w : bool, b : Array, wkp : Vector2, bkp : Vector2, ep, wk : bool,
bk : bool, wrl : bool, wrr : bool, brl : bool, brr : bool, scc : int,
loc : int):
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
	side_change_count = scc
	light_off_count = loc

func get_board(b: Array):
	board = b

func get_piece_for_switching(piece):
	piece_for_switching = piece
