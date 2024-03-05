extends Node
class_name WebSocketClient

signal connected
signal disconnected

signal new_message

signal ready_state

@export var url = "ws://localhost/vis"

var ws = WebSocketPeer.new()
var wsUrl = ""

var is_connected = false
var last_state = WebSocketPeer.STATE_CLOSED

# Called when the node enters the scene tree for the first time.
func _ready():
	var urlParam = JavaScriptBridge.eval("""
			var wsUrl = new URL(\"""" + url + """\");
			var url = new URL(window.location.href);
			wsUrl.port = url.port;
			window.wsUrl = wsUrl;
			wsUrl.toString();
		""")
	
	if urlParam == null:
		wsUrl = url
	else:
		wsUrl = urlParam

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ws.poll()
	var state = ws.get_ready_state()
	
	if state != last_state:
		ready_state.emit(state)
		last_state = state
	
	if state == WebSocketPeer.STATE_CONNECTING:
		pass
		
	elif state == WebSocketPeer.STATE_OPEN:
		if !is_connected:
			is_connected = true
			connected.emit()
		
		while ws.get_available_packet_count():
			new_message.emit(ws.get_packet())
		
	elif state == WebSocketPeer.STATE_CLOSING:
		#print("closing")
		pass
		
	elif state == WebSocketPeer.STATE_CLOSED:
		if is_connected:
			is_connected = false
			
			var code = ws.get_close_code()
			var reason = ws.get_close_reason()
			print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			
			disconnected.emit(code)
			
			var err = ws.connect_to_url(wsUrl)
			if err:
				printerr(err)
