extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

const Player = preload("res://Scenes/Sonic.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

const Cam = preload("res://Scenes/MainCam.tscn")

func _on_host_button_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_join_button_pressed():
	main_menu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	#var cam = Cam.instantiate()
	#cam.player = player
	add_child(player, true)
	#add_child(cam)
