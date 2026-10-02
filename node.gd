extends GraphNode

var port1Connect = null
var port2Connect = null
var port3Connect = null

var connectingTo

# Dialogue Data
var charName : String = ""
var voice : String = ""
var tone : String = ""
var ID : String = "" # In my game, it's stored as a string. In other games this may be different.
var dialogue : String = ""
var startCommands : Array = []
var talkCommands : Array = []
var endCommands : Array = []
var hasOptions : bool = false
var continuity : Dictionary = { # handles dialogue options and what IDs they lead to. If no choices, defaults to just Option 1's ID
	# Option 1 : ID
	# Option 2: ID
	# Option 3 : ID
}


func _process(delta):
	if $Options/extraSettings.button_pressed:
		$Options/option1.visible = true
		$Options/option2.visible = true
		$Options/option3.visible = true
		$Options/startFunctions.visible = true
		$Options/talkFunctions.visible = true
		$Options/endFunctions.visible = true
		set_slot_enabled_right(2, true)
		$SLOT3.visible = true
		custom_minimum_size.y = 1050
		hasOptions = true
	else:
		$Options/option1.visible = false
		$Options/option2.visible = false
		$Options/option3.visible = false
		$Options/startFunctions.visible = false
		$Options/talkFunctions.visible = false
		$Options/endFunctions.visible = false
		set_slot_enabled_right(2, false)
		$SLOT3.visible = false
		custom_minimum_size.y = 424
		hasOptions = false


func _on_slot_updated(slot_index):
	pass

func _on_delete_request():
	queue_free()


func _on_resize_request(new_size):
	size = new_size


# Changing dialogue variables from node

func _on_character_name_text_changed(new_text):
	charName = new_text

func _on_voice_text_changed(new_text):
	voice = new_text
	
func _on_tone_text_changed(new_text):
	tone = new_text
	
func _on_id_text_changed(new_text):
	ID = new_text
	
func _on_dialogue_text_changed():
	dialogue = $Dialogue.text

func _on_start_functions_text_changed():
	var textBoxText : String = $Options/startFunctions.text
	var commandsToParse : Array = textBoxText.split("\n",false,0)
	startCommands = []
	for i in commandsToParse:
		startCommands.append(functionToKey(i))
	
func _on_talk_functions_text_changed():
	return
	
func functionToKey(function):
	var argumentArray : Array = []
	var resultingDict : Dictionary = {}
	if "(" in function:
		if not ")" in function:
			push_warning("Unmatched parenthesis in function call")
		else:
			var startIdx = function.find("(")
			var endIdx = function.find(")")
			var length = endIdx - (startIdx + 1)
			var arguments = "[" + function.substr(startIdx + 1, length) + "]"
			if str_to_var(arguments) is not Array:
				push_warning("Your arguments are invalid. Check if you put a comma inside of a string without an escape character (Ex: \"Value,\")")
			else:
				argumentArray = str_to_var(arguments)
	# assembling keys
	var functionName = function.substr(0,function.find("("))
	resultingDict["action"] = functionName
	
	var nameAndTypes := []
	for i in argumentArray:
		var argumentStringified = str(i)
		nameAndTypes.append( {
			"type" : type_string(typeof(i)).to_lower(),
			"value" : argumentStringified
		}, )
		
	resultingDict["args"] = nameAndTypes
	return(resultingDict)
	
