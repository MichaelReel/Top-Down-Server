extends Node

var network = NetworkedMultiplayerENet.new()
var authentication_api = MultiplayerAPI.new()
var ip = "localhost"
var port = "1983"

onready var gameserver = get_node("/root/Server")

func _ready():
	connect_to_server()

func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server():
	network.create_client(ip, port)
	set_custom_multiplayer(authentication_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed():
	print("Failed to connect to the game server authentication hub")

func _on_connection_succeeded():
	print("Successfully connected to the game server authentication hub")

remote func receive_login_token(token):
	gameserver.place_expected_token(token)
	rpc_id(1, "login_token_readied", token)
