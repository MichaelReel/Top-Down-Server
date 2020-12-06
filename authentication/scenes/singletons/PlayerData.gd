extends Node

func authenticate_player(username, password):
	print("Exposing user " + username + " and their password!: " + password)
	if username == "munch" and password == "munch":
		return true
	else:
		return false
