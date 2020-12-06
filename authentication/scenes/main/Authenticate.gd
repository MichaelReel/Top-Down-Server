extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1982
var max_servers = 5

func _ready():
	start_server()

func start_server():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " connected")

func _peer_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " disconnected")

remote func authenticate_player(username, password, player_id):
	print("authentication rquest received")
	var gateway_id = get_tree().get_rpc_sender_id()
	var result = PlayerData.authenticate_player(username, password)
	rpc_id(gateway_id, "authentication_results", result, player_id)
	print("returning result " + str(result) + " to gateway " + str(gateway_id) + " for player " + str(player_id))
