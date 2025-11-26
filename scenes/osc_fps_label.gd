extends Label

var last_rx_time = 0
var delta_time = 1

var osc_connected = false

func _message_received(_msg, _value, _time):
	var time = Time.get_ticks_usec()
	if not osc_connected:
		osc_connected = true
		add_theme_color_override("font_color", Color.LIME_GREEN)
		set_text("... OSC")
	$Timeout.start()
	var dt = time - last_rx_time
	if dt > 10000: # 10ms
		delta_time = dt
		last_rx_time = time
		set_text("%d OSC" % (1000000.0 / delta_time))

func _ready() -> void:
	OscServer.message_received.connect(_message_received)


func _on_timeout_timeout() -> void:
	add_theme_color_override("font_color", Color.RED)
	set_text("OSC OFF")
	osc_connected = false
