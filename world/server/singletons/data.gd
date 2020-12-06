extends Node

var skill_data

func _ready():
	var skill_data_file = File.new()
	skill_data_file.open("res://data/test_data.json", File.READ)
	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
	skill_data_file.close()
	skill_data = skill_data_json.result

func get_skill_data(key_path : String):
	var key_list : Array = key_path.split("/")
	var data = skill_data
	while data and not key_list.empty():
		data = data[key_list.pop_front()]
	# May want to revoke this, for now, don't return whole dictionaries
	if data is Dictionary or data == null:
		return null
	return data
