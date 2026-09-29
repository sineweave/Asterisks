extends Control
var graphNode = preload("res://Node.tscn")

func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	var fromNode = $GraphEdit.get_node(NodePath(from_node))
	var toNode = $GraphEdit.get_node(NodePath(to_node))
	$GraphEdit.connect_node(from_node, from_port, to_node, to_port)
	print(from_node)
	print(to_node)
	var connectionList = $GraphEdit.get_connection_list()
	for i in connectionList:
		print("From: " + str(i["from_node"]))
		print("To: " + str(i["to_node"]))


func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	$GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)



func _on_graph_edit_connection_to_empty(from_node, from_port, release_position):
	for connection in $GraphEdit.get_connection_list():
			if connection.from_node == from_node and connection.from_port == from_port:
				$GraphEdit.disconnect_node(from_node, from_port, connection.to_node, connection.to_port)
				break


func _on_graph_edit_connection_from_empty(to_node, to_port, release_position):
	for connection in $GraphEdit.get_connection_list():
		if connection.to_node == to_node and connection.to_port == to_port:
			$GraphEdit.disconnect_node(connection.from_node, connection.from_port, to_node, to_port)
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
