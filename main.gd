
extends Control
var graphNode = preload("res://Node.tscn")
var connections : Array = []

# User controlled variables
var customExtensions : Array = []
var startNode : int = 0

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
			fromNode.configConnections()
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
	if file == null or ($FileLoader.current_path.get_extension() != "json" and not customExtensions.has($FileLoader.current_path.get_extension())):
		# second condition compares against anything inside of the custom file extensions array. Users can edit this array to add their custom file types to it
		printerr("Error opening file. Did you load a .json just now? ",FileAccess.get_open_error())
		return
	else:
		var loadedDict = JSON.parse_string(file.get_as_text())
		if loadedDict is not Dictionary or not loadedDict.has("nodes"):
			printerr("File not loaded, improper format. Check your file to see if it uses Asterisks' format.")
			return
		dictionary = loadedDict

	for i in $GraphEdit.get_connection_list():
		$GraphEdit.disconnect_node(i["from_node"], i["from_port"], i["to_node"], i["to_port"])

	for i in $GraphEdit.get_children():
		if i.is_in_group("Graph Node"):
			$GraphEdit.remove_child(i)
			i.queue_free()
			
	startNode = int(dictionary.get("start_node", 0))

	# Building new nodes
	for i in dictionary["nodes"]:
		var node = graphNode.instantiate()
		node.name = i["editor_name"]
		$GraphEdit.add_child(node)
		node.end = i["end"]
		if i["end"]:
			node.get_node("Options/end").button_pressed = true
		node.get_node("Options/characterName").text = i["npc"]
		node.get_node("Options/voice").text = i["voice"]
		node.get_node("Options/tone").text = i["tone"]
		node.get_node("Options/ID").text = str(i["id"])
		node.ID = int(i["id"])
		node.get_node("Options/Dialogue").text = i["text"]
		node.charName = i["npc"]
		node.voice = i["voice"]
		node.tone = i["tone"]
		node.dialogue = i["text"]
		node.startCommands = i.get("startCommands", [])
		node.talkCommands = i.get("talkCommands", [])
		node.endCommands = i.get("endCommands", [])
		if node.startCommands != [] or node.talkCommands != [] or node.endCommands != []:
			node.get_node("Options/extraSettings").button_pressed = true
			node.get_node("Options/startFunctions").text = functionReferenceToString(node.startCommands)
			node.get_node("Options/talkFunctions").text = functionReferenceToString(node.talkCommands)
			node.get_node("Options/endFunctions").text = functionReferenceToString(node.endCommands)
		if i.has("options"):
			node.get_node("Options/extraSettings").button_pressed = true
			node.hasOptions = true
			for optionIndex in range(min(i["options"].size(), 3)):
				var option = i["options"][optionIndex]
				var port = int(option.get("port", optionIndex))
				if port >= 0 and port < 3:
					node.get_node("Options/option" + str(port + 1)).text = str(option["text"])
					node.continuity[option["text"]] = option["next"]
		elif i.has("next"):
			node.continuity = {"next" : str(i["next"])}
		if node.ID == startNode:
			node.get_node("Options/start").button_pressed = true
	
	var graphNodesByID : Dictionary = {}
	for i in get_tree().get_nodes_in_group("Graph Node"):
		if i.get_parent() == $GraphEdit:
			graphNodesByID[str(i.ID)] = i
		
	# Connecting the nodes
	for i in get_tree().get_nodes_in_group("Graph Node"):
		if i.get_parent() != $GraphEdit:
			continue
		for option in i.continuity:
			var targetID = str(i.continuity[option])
			if graphNodesByID.has(targetID):
				var port = 0
				if i.hasOptions:
					port = -1
					for optionIndex in range(3):
						if i.get_node("Options/option" + str(optionIndex + 1)).text == option:
							port = optionIndex
							break
				if port >= 0:
					$GraphEdit.connect_node(i.name, port, graphNodesByID[targetID].name, 0)
			
func functionReferenceToString(references):
	var result : String = ""
	var args : String = ""
	for i in references:
		args = ""
		
		for o in i["args"]:
			if args != "":
				args  += ","
			if o["type"] == "string":
				args += JSON.stringify(o["value"])
			else:
				args += str(o["value"])
		
		if result != "":
			result += "\n"
		result += (i["action"] + "(" + args + ")")
	return(result)


func exportJson():
	var dictionary : Dictionary = {}
	dictionary["nodes"] = []
	var file : FileAccess = FileAccess.open($FileExporter.current_path,FileAccess.WRITE_READ) 
	if file == null:
		printerr("Error opening export file: ",FileAccess.get_open_error())
		return

	for i in get_tree().get_nodes_in_group("Graph Node"):
		if i.get_parent() == $GraphEdit:
			i.ID = int(i.get_node("Options/ID").text)
			i.charName = i.get_node("Options/characterName").text
			i.voice = i.get_node("Options/voice").text
			i.tone = i.get_node("Options/tone").text
			i.dialogue = i.get_node("Options/Dialogue").text
			i.end = i.get_node("Options/end").button_pressed
			i.hasOptions = i.get_node("Options/extraSettings").button_pressed
			i._on_start_functions_text_changed()
			i._on_talk_functions_text_changed()
			i._on_end_functions_text_changed()

	for i in get_tree().get_nodes_in_group("Graph Node"):
		if i.get_parent() == $GraphEdit:
			i.configConnections()

	for i in get_tree().get_nodes_in_group("Graph Node"):
		if i.get_parent() != $GraphEdit:
			continue
		var nodeDict = {}
		nodeDict["editor_name"] = i.name
		nodeDict["end"] = i.end
		nodeDict["endCommands"] = i.endCommands
		nodeDict["id"] = str(i.ID)
		nodeDict["npc"] = i.charName
		if i.hasOptions:
			var options = []
			for port in range(3):
				var optionText = i.get_node("Options/option" + str(port + 1)).text
				if i.continuity.has(optionText):
					options.append({"text" : optionText, "next" : i.continuity[optionText], "port" : port})
			nodeDict["options"] = options
		elif i.continuity.has("next"):
			nodeDict["next"] = str(i.continuity["next"])
		nodeDict["startCommands"] = i.startCommands
		nodeDict["talkCommands"] = i.talkCommands
		nodeDict["endCommands"] = i.endCommands
		nodeDict["text"] = i.dialogue
		nodeDict["tone"] = i.tone
		nodeDict["voice"] = i.voice
		dictionary["nodes"].append(nodeDict)
	
	for i in get_tree().get_nodes_in_group("Graph Node"):
		if i.get_parent() == $GraphEdit and i.get_node("Options/start").button_pressed:
			startNode = i.ID
			break

	dictionary["start_node"] = startNode
	var json = JSON.stringify(dictionary, "	")
	file.store_string(json)
	file.close()

func _on_exit_settings_pressed():
	$settings.hide()


func _on_settings_button_pressed():
	$settings.show()
	

func _on_extensions_text_changed():
	customExtensions = ($settings/extensions.text).split(",")


func _on_file_exporter_confirmed():
	exportJson()


func _on_export_pressed():
	$FileExporter.show()


func _on_file_exporter_canceled():
	$FileExporter.hide()


func _on_graph_edit_connection_drag_started(from_node, from_port, is_output):
	if not is_output:
		$GraphEdit.force_connection_drag_end()
