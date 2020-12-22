extends Node

signal token_placed(token)

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1983
var max_players = 100

var game_server_list = {}
var game_id_map = {}


func _ready():
	start_server()

func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func start_server():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Authentication game world service started on port " + str(port))
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(gameserver_id):
	# TODO: Accomodate multiple game worlds with load balancing
	var game_server_name = "GameServer1"
	game_server_list[game_server_name] = gameserver_id
	game_id_map[gameserver_id] = game_server_name
	print(game_server_list)

func _peer_disconnected(gameserver_id):
	var game_server_name = game_id_map[gameserver_id]
	game_id_map.erase(gameserver_id)
	game_server_list.erase(game_server_name)
	print(game_server_list)

func distribute_login_token(token, game_server_name):
	var game_server_id = game_server_list[game_server_name]
	rpc_id(game_server_id, "receive_login_token", token)

remote func login_token_readied(token):
	emit_signal("token_placed", token)
