extends Node3D

#@onready var main_menu = $CanvasLayer/MainMenu
#@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@export var main_menu: PanelContainer
@export var address_entry: LineEdit

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


func _ready():
	GlobalVariables.server_node = self


func _on_host_button_pressed():
	add_player()
	
	#var ability_selection_menu = Instantiables.create(Instantiables.objects.ABILITYSELECT)
	#add_child(ability_selection_menu, true)


func add_player():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(Instantiables.add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	# store the character's unique id on gloabal variables to be
	# set in the character after the ability selection is done
	var unique_id = multiplayer.get_unique_id()
	GlobalVariables.character_id = unique_id
	
	GlobalVariables.main_menu.after_online_setup()


func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_join_button_pressed():
	main_menu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

