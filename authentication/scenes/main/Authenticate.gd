extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1982
var max_servers = 5

var token_stack = {}

func _ready():
	start_server()

func start_server():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication gateway service started on port " + str(port))
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	GameServers.connect("token_placed", self, "_token_placed")

func _peer_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " connected")

func _peer_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " disconnected")

remote func authenticate_player(username, password, player_id):
	print("authentication rquest received")
	var token
	var gateway_id = get_tree().get_rpc_sender_id()
	var result = PlayerData.authenticate_player(username, password)
	if result:
		
		randomize()
		var random_number = randi()
		var hashed = str(random_number).sha256_text()
		var timestamp = str(OS.get_unix_time())
		token = hashed + timestamp
		print(token)
		var gameserver = "GameServer1"  # Needs load balanced
		token_stack[token] = {'gateway_id': gateway_id, 'player_id': player_id}
		GameServers.distribute_login_token(token, gameserver)
	else:
		forward_result_to_client(gateway_id, false, player_id, token)

func _token_placed(token):
	if not token_stack.has(token):
		print("Unrecognised token: " + token)
		return
	var client_data = token_stack[token]
	token_stack.erase(token)
	forward_result_to_client(client_data['gateway_id'], true, client_data['player_id'], token)

func forward_result_to_client(gateway_id, result, player_id, token):
	rpc_id(gateway_id, "authentication_results", result, player_id, token)
	print("returning result " + str(result) + " to gateway " + str(gateway_id) + " for player " + str(player_id))
