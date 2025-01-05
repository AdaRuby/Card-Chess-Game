extends Node3D

var card_height : float = 0.02
var new_w_size : float
var new_b_size : float

@onready var deck_w_ref: Node2D = $"../../w_camera/w_cards/Deck"
@onready var deck_b_ref: Node2D = $"../../b_camera/b_cards/Deck_b"
@onready var deck_model_w: MeshInstance3D = $deck_model_w
@onready var deck_model_b: MeshInstance3D = $deck_model_b


func _ready() -> void:
	update_deck_size()
	if self.name == "deck_w":
		deck_model_b.visible = false
	elif self.name == "deck_b":
		deck_model_w.visible = false

func update_deck_size():
	new_w_size = card_height * w_deck_size()
	deck_model_w.mesh.size = Vector3(1, new_w_size, 1.5)
	
	new_b_size = card_height * b_deck_size()
	deck_model_b.mesh.size = Vector3(1, new_b_size, 1.5)

func w_deck_size():
	return deck_w_ref.get_w_deck_size()

func b_deck_size():
	return deck_b_ref.get_b_deck_size()
