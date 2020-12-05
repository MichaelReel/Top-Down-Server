extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1980
var max_players = 100

func _ready():
	start_server()

func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(player_id):
	print("User " + str(player_id) + " connected")

func _peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected")

remote func fetch_skill_data(key_path : String, inst_id : String):
	var player_id = get_tree().get_rpc_sender_id()
	var value = ServerData.get_skill_data(key_path)
	rpc_id(player_id, "return_skill_data", value, inst_id)
	print("sending " + str(value) + " to player " + str(player_id) + " for inst " + str(inst_id) + " by key " + key_path)
