extends Node

export (PackedScene) var player_container_scene

onready var main_interface = get_parent()

var awaiting_verification := {}

func start(player_id):
	awaiting_verification[player_id] = OS.get_unix_time()
	main_interface.fetch_token(player_id)

func verify(player_id, token):
	var token_verification = false
	if main_interface.expected_tokens.has(token):
		token_verification = true
		create_player_container(player_id)
		main_interface.expected_tokens.erase(token)
		# TODO: Not fussed on the reaching into main_interface here ^ and below
	awaiting_verification.erase(player_id)
	main_interface.return_token_verification_results(player_id, token_verification)
	if not token_verification:
		main_interface.network.disconnect_peer(player_id)

func _on_VerificationExpiry_timeout():
	var current_time = OS.get_unix_time()
	var start_time : int
	if awaiting_verification.empty():
		pass
	else:
		for player_id in awaiting_verification.keys():
			start_time = awaiting_verification[player_id]
			if current_time - start_time > 30:
				awaiting_verification.erase(player_id)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if connected_peers.has(player_id):
					main_interface.return_token_verification_results(player_id, false)
					main_interface.network.disconnect_peer(player_id)
	print("Awaiting verification:")
	print(awaiting_verification)

func create_player_container(player_id):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(player_id))
	fill_player_container(player_container)

func fill_player_container(player_container):
	player_container.player_stats = ServerData.test_data.Stats

func stop(player_id):
	drop_player_container(player_id)

func drop_player_container(player_id):
	var player_container = get_node("../" + str(player_id))
	# Should save data here
	player_container.queue_free()

