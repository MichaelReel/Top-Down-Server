extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1980
var max_players = 100

var expected_tokens = {}

onready var player_verification_process = $PlayerVerification
onready var combat_functions = $Combat

func _ready():
	start_server()

func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Game world server started on port " + str(1980))
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(player_id):
	print("User " + str(player_id) + " connected")
	player_verification_process.start(player_id)

func _peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected")
	player_verification_process.stop(player_id)

func place_expected_token(token):
	expected_tokens[token] = OS.get_unix_time()

func _on_TokerExpiry_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens.empty():
		return
	else:
		for token in expected_tokens.keys():
			token_time = expected_tokens[token]
			if current_time - token_time > 30:
				expected_tokens.erase(token)
	print("Expected tokens:")
	print(expected_tokens)

func fetch_token(player_id):
	rpc_id(player_id, "fetch_token")

func return_token_verification_results(player_id, result):
	rpc_id(player_id, "return_token_verification_results", result)

remote func return_token(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.verify(player_id, token)

remote func fetch_skill_data(key_path : String, inst_id : String):
	var player_id = get_tree().get_rpc_sender_id()
	var value = ServerData.get_skill_data(key_path)
	rpc_id(player_id, "return_skill_data", value, inst_id)
	print("sending " + str(value) + " to player " + str(player_id) + " for inst " + str(inst_id) + " by key " + key_path)

remote func fetch_player_stats(inst_id : String):
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = get_node(str(player_id)).player_stats
	print("returning stats: " + str(player_stats))
	rpc_id(player_id, "return_player_stats", player_stats, inst_id)


