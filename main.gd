extends Control
var graphNode = preload("res://Node.tscn")
var connections : Array = []
func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	var fromNode = $GraphEdit.get_node(NodePath(from_node))
	var toNode = $GraphEdit.get_node(NodePath(to_node))
	$GraphEdit.connect_node(from_node, from_port, to_node, to_port)
	connections.clear()
	connections = $GraphEdit.get_connection_list()
	fromNode.configConnections()
	


func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	var fromNode = $GraphEdit.get_node(NodePath(from_node))
	$GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)
	fromNode.configConnections()


func _on_graph_edit_connection_from_empty(to_node, to_port, release_position):
	for connection in $GraphEdit.get_connection_list():
		if connection.to_node == to_node and connection.to_port == to_port:
			var fromNode = $GraphEdit.get_node(NodePath(connection.from_node))
			var fromPort = connection.from_port
			$GraphEdit.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			var optionText = fromNode.get_node("Options/option" + str(fromPort + 1)).text
			fromNode.continuity.erase(optionText)
			break


func _on_create_pressed():
	var node = graphNode.instantiate()
	node.name = "Node_" + str($GraphEdit.get_child_count() - 4)
	$GraphEdit.add_child(node)


func _on_delete_pressed():
	for node in get_tree().get_nodes_in_group("Graph Node"):
		if node.selected:
			for connected in $GraphEdit.get_connection_list():
				if connected["from_node"] == node.name or connected["to_node"] == node.name:
					$GraphEdit.disconnect_node(connected["from_node"], connected["from_port"], connected["to_node"], connected["to_port"])
					# Disconnects the node from other nodes
			node.queue_free() # Deletes the node


func _on_load_pressed():
	$FileLoader.show()


func _on_file_loader_canceled():
	$FileLoader.hide()
	



func _on_file_loader_confirmed():
	loadJson()
	
func _on_file_loader_file_selected(path):
	loadJson()
	
	
func loadJson():
	var dictionary : Dictionary = {}
	var file : FileAccess = FileAccess.open($FileLoader.current_path,FileAccess.READ) 
	if file == null or $FileLoader.current_path.get_extension() != "json":
		printerr("Error opening file. Did you load a .json just now? ",FileAccess.get_open_error())
		return
	else:
		dictionary = JSON.parse_string(file.get_as_text())
	for i in $GraphEdit.get_children():
		if i.is_in_group("Graph Node"):
			i.queue_free()
			
	# Building new nodes
	for i in dictionary["nodes"]:
		var node = graphNode.instantiate()
		node.name = i["editor_name"]
		node.get_node("Options/characterName").text = i["npc"]
		node.get_node("Options/voice").text = i["voice"]
		node.get_node("Options/tone").text = i["tone"]
		node.get_node("Options/ID").text = i["id"]
		node.ID = int(i["id"])
		node.get_node("Options/Dialogue").text = i["text"]
		if i["startCommands"] != [] or i["talkCommands"] != [] or i["endCommands"] != []:
			node.get_node("Options/extraSettings").button_pressed = true
			node.get_node("Options/startFunctions").text = functionReferenceToString(i["startCommands"])
			node.get_node("Options/talkFunctions").text = functionReferenceToString(i["talkCommands"])
			node.get_node("Options/endFunctions").text = functionReferenceToString(i["endCommands"])
		$GraphEdit.add_child(node)
		if i["options"] != []:
			node.get_node("Options/extraSettings").button_pressed = true
			node.get_node("Options/option1").text = i["options"][0]["text"]
			node.get_node("Options/option2").text = i["options"][1]["text"]
			node.get_node("Options/option3").text = i["options"][2]["text"]
			node.continuity = {i["options"][0]["text"] : i["options"][0]["next"],
			i["options"][1]["text"] : i["options"][1]["next"],
			i["options"][2]["text"] : i["options"][2]["next"]}
		elif i.has("next"):
			node.continuity = {"Next" : str(i["next"])}
	
	var graphNodesByID : Dictionary = {}		
	for i in get_tree().get_nodes_in_group("Graph Node"):
		graphNodesByID[str(i.ID)] = i
		
	# Connecting the nodes
	for i in get_tree().get_nodes_in_group("Graph Node"):
		for connection in i.continuity:
			for port in i.continuity.size():
				if i.continuity.size() == 1:
					$GraphEdit.connect_node(i.name, port, graphNodesByID[i.continuity["Next"]].name, 0)
				elif i.get_node("Options/option" + str(port + 1)).text == connection:
					$GraphEdit.connect_node(i.name, port, graphNodesByID[(i.continuity[connection])].name, 0)
			
func functionReferenceToString(references):
	var result : String = ""
	var args : String = ""
	for i in references:
		args = ""
		
		for o in i["args"]:
			if args != "":
				args  += ","
			if o["type"] == "string":
				args += ("\"" + o["value"] + "\"")
			else:
				args += str(o["value"])
		
		result += ("\n" + i["action"] + "(" + args + ")")
	return(result)
