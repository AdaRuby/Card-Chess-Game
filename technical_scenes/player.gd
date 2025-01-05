extends CharacterBody3D

@onready var game_scene = load("res://main_game_scene/main_game_screen.tscn").instantiate()
@onready var w_camera = game_scene.get_node("w_camera")
@onready var b_camera = game_scene.get_node("b_camera")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var player_id = 1:
	set(id):
		player_id = id

#func _ready() -> void:
	#print("camera" + str(multiplayer.get_unique_id()))
	#if multiplayer.get_unique_id() == 1:
		#w_camera.current = true
	#else: b_camera.current = true
	
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity += get_gravity() * delta

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
