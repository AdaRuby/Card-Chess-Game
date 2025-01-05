extends Control

const port = 135
const adress = "127.0.0.1"

var peer
var number_of_players : int = 0

#@onready var player_scene = load("res://technical_scenes/player.tscn")
@onready var choice_scene = load("res://main_game_scene/character_choice.tscn").instantiate()
var player_spawn

@onready var start_button: Button = $multiplayer_menu/startgame
@onready var choice: Label = $multiplayer_menu/Label
@onready var waiting_line: Label = $multiplayer_menu/Label2
@onready var m_buttons: VBoxContainer = $multiplayer_menu/m_buttons
@onready var side_buttons: VBoxContainer = $multiplayer_menu/side_buttons
@onready var w_button: Button = $multiplayer_menu/side_buttons/white
@onready var b_button: Button = $multiplayer_menu/side_buttons/black
@onready var side_text: Label = $multiplayer_menu/Label3
@onready var modes: VBoxContainer = $modes
@onready var multiplayer_menu: VBoxContainer = $multiplayer_menu
@onready var waiting_for_player: Label = $multiplayer_menu/Label4
@onready var menu_music: AudioStreamPlayer = $menu_music
@onready var button_sound: AudioStreamPlayer = $button_sound
@onready var menu_buttons: VBoxContainer = $menu_buttons
@onready var back_button: Button = $back_button
@onready var exit_button: Button = $menu_buttons/exit


func _ready() -> void:
	#get_viewport().size = DisplayServer.screen_get_size()
	
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func player_connected(id) -> void:
	side_buttons.visible = true
	waiting_for_player.visible = false
	print("Player connected: " + str(id))
	
func player_disconnected(id) -> void:
	print("Player disconnected: " + str(id))

func connected_to_server() -> void:
	print("You connected to server")
	send_player_info.rpc_id(1, multiplayer.get_unique_id())

func connection_failed() -> void:
	print("Connection failed")

@rpc("any_peer")
func send_player_info(id) -> void:
	if !PlayerInfo.Players.has(id):
		PlayerInfo.Players[id] = {
			"id" : id
		}
	if multiplayer.is_server():
		for i in PlayerInfo.Players:
			send_player_info.rpc(i)

@rpc("any_peer", "call_local")
func start_game() -> void:
	menu_music.stop()
	self.hide()

#@rpc("any_peer")
#func add_player(id) -> void:
	#var player = player_scene.instantiate()
	#player.player_id = id
	#player.name = str(id)
	#player_spawn.add_child(player)
	#print("player added")

func _on_host_pressed() -> void:
	#get_tree().root.add_child(choice_scene)
	#get_tree().root.add_child(game_scene)
	#player_spawn = game_scene.get_node("Players")
	#game_scene.hide_cards()

	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host" + str(error))
		return
	multiplayer.set_multiplayer_peer(peer)
	
	m_buttons.visible = false
	#side_buttons.visible = true
	waiting_for_player.text = "Waiting for player to join."
	waiting_for_player.visible = true
	
	GameManadger.solo = false
	GameManadger.multi = true
	
	send_player_info(peer.get_unique_id())
	#multiplayer.peer_connected.connect(add_player)
	#add_player(1)
	button_sound.play()


func _on_join_pressed() -> void:
	#get_tree().root.add_child(choice_scene)
	#get_tree().root.add_child(game_scene)
	#game_scene.hide_cards()
	
	peer = ENetMultiplayerPeer.new()
	peer.create_client(adress, port)
	multiplayer.set_multiplayer_peer(peer)
	
	m_buttons.visible = false
	side_buttons.visible = true
	
	GameManadger.solo = false
	GameManadger.multi = true
	
	button_sound.play()


func _on_startgame_pressed() -> void:
	start_game.rpc()
	print("game is stating!")
	print(PlayerInfo.Players)
	button_sound.play()


func _on_white_pressed() -> void:
	if !PlayerInfo.chose_white:
		choice.visible = true
		w_button.visible = false
	else:
		var id = multiplayer.get_unique_id()
		if PlayerInfo.Players.has(id):
			PlayerInfo.Players["side"] = "white"
		side_buttons.visible = false
		if multiplayer.is_server():
			start_button.visible = true
		else:
			waiting_line.visible = true
		side_text.text = "You chose white side!"
		side_text.visible = true
		choice.visible = false
		white_chosen.rpc()
	button_sound.play()
	get_tree().root.add_child(choice_scene)

func _on_black_pressed() -> void:
	if !PlayerInfo.chose_black:
		choice.visible = true
		b_button.visible = false
	else:
		var id = multiplayer.get_unique_id()
		if PlayerInfo.Players.has(id):
			PlayerInfo.Players["side"] = "black"
		side_buttons.visible = false
		if multiplayer.is_server():
			start_button.visible = true
		else:
			waiting_line.visible = true
		side_text.text = "You chose black side!"
		side_text.visible = true
		choice.visible = false
		black_chosen.rpc()
	button_sound.play()
	get_tree().root.add_child(choice_scene)

@rpc("any_peer")
func white_chosen():
	PlayerInfo.chose_white = false

@rpc("any_peer")
func black_chosen():
	PlayerInfo.chose_black = false


func _on_solo_pressed() -> void:
	modes.visible = false
	get_tree().root.add_child(choice_scene)
	#get_tree().root.add_child(game_scene)
	start_game()
	button_sound.play()

func _on_multi_pressed() -> void:
	modes.visible = false
	multiplayer_menu.visible = true
	button_sound.play()

func _on_play_pressed() -> void:
	menu_buttons.visible = false
	modes.visible = true
	back_button.visible = true
	button_sound.play()

func _on_lore_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://technical_scenes/lore_menu.tscn")

func _on_settings_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://technical_scenes/settings_menu.tscn")
	
func _on_exit_pressed() -> void:
	button_sound.play()
	get_tree().quit()

func _on_back_button_pressed() -> void:
	if modes.visible: 
		modes.visible = false
		menu_buttons.visible = true
		back_button.visible = false
	if multiplayer_menu.visible: 
		multiplayer_menu.visible = false
		modes.visible = true
	button_sound.play()
