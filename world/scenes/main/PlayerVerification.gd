extends Node

export (PackedScene) var player_container_scene

func start(player_id):
	"""
	Token stuff here
	"""
	create_player_container(player_id)

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
