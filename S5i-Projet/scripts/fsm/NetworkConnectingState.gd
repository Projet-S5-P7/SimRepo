class_name NetworkFSMConnectingState
extends StateMachineState


# Called when the state machine enters this state.
func on_enter() -> void:
	print("Network Connecting State entered")
	# You should connect to the websocket server here. With the socket variable of NetworkFSM
	get_parent().socket.connect_to_url("ws://127.0.0.1:8765") # Port à chang
	

# Called every frame when this state is active.
func on_process(delta: float) -> void:
	# Ne pas connecter dans on_process, seulement interroger l'état et utiliser poll
	get_parent().socket.poll()  # Interroge les événements WebSocket
	
	var state = get_parent().socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_CONNECTING:
		# Could be nice to have a blinker showing that's it's trying to connect?
		print("websocket connection ")
		
		
		
	
	elif state == WebSocketPeer.STATE_OPEN:
		# Do stuff here
		print("websocket ouvert")
		
		#json a changer
		var json_data = {
			"message": "Hello, WebSocket!"
			}
		var json_string = JSON.stringify(json_data)  # Convertir le dictionnaire en chaîne JSON
		var byte_array = json_string.to_utf8_buffer()  # Convertir la chaîne en PackedByteArray
		print("message convertie")
		var result = get_parent().socket.put_packet(byte_array)  # Envoyer le tableau d'octets
		
		print("après envoie")

		if result == OK:
			print("JSON data sent successfully: ", json_string)
		else:
			print("Failed to send JSON data. Result: ", result)
	
	elif state == WebSocketPeer.STATE_CLOSED or state == WebSocketPeer.STATE_CLOSING:
		# Do stuff here
		print("websocket close")
		get_parent().socket.connect_to_url("ws://127.0.0.1:8765")

# Called every physics frame when this state is active.
func on_physics_process(delta: float) -> void:
	pass

# Called when there is an input event while this state is active.
func on_input(event: InputEvent) -> void:
	pass

# Called when the state machine exits this state.
func on_exit() -> void:
	print("Network Connecting State left")
