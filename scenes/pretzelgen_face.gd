extends Node3D

@onready var smile_id = $face.find_blend_shape_by_name("smile")
@onready var frown_id = $face.find_blend_shape_by_name("frown")
@onready var mouth_open_id = $face.find_blend_shape_by_name("mouth open")
@onready var jaw_forward_id = $face.find_blend_shape_by_name("jaw forward")
@onready var pucker_id = $face.find_blend_shape_by_name("mouth pucker")
@onready var funnel_id = $face.find_blend_shape_by_name("mouth funnel")


func _process(_delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	
	# breathe
	$face.position.y = 0.0003 * sin(t)
	$faceL.position.y = 0.0003 * sin(t)
	
	#
	# SMILE (already working)
	#
	var smile_right = OscServer.incoming_messages.get("/mouthSmileRight", [0])[0]
	var smile_left = OscServer.incoming_messages.get("/mouthSmileLeft", [0])[0]
	$face.set_blend_shape_value(smile_id, smile_right)
	$faceL.set_blend_shape_value(smile_id, smile_left)


	#
	# FROWN
	#
	var frown_right = OscServer.incoming_messages.get("/mouthFrownRight", [0])[0]
	var frown_left = OscServer.incoming_messages.get("/mouthFrownLeft", [0])[0]
	$face.set_blend_shape_value(frown_id, frown_right)
	$faceL.set_blend_shape_value(frown_id, frown_left)


	#
	# MOUTH OPEN  ( uses jawOpen and mouthClose )
	#
	var jaw_open = OscServer.incoming_messages.get("/jawOpen", [0])[0]
	var mouth_close = OscServer.incoming_messages.get("/mouthClose", [0])[0]
	var mouth_open = jaw_open - mouth_close
	$face.set_blend_shape_value(mouth_open_id, mouth_open)
	$faceL.set_blend_shape_value(mouth_open_id, mouth_open)


	#
	# JAW FORWARD
	#
	var jaw_forward = OscServer.incoming_messages.get("/jawForward", [0])[0]
	$face.set_blend_shape_value(jaw_forward_id, jaw_forward)
	$faceL.set_blend_shape_value(jaw_forward_id, jaw_forward)


	#
	# PUCKER  (mouthPucker)
	#
	var pucker = OscServer.incoming_messages.get("/mouthPucker", [0])[0]
	
	# add some pucker for jaw open + mouth close
	pucker += 0.25 * (jaw_open * mouth_close)
	
	$face.set_blend_shape_value(pucker_id, pucker)
	$faceL.set_blend_shape_value(pucker_id, pucker)


	#
	# FUNNEL  (mouthFunnel)
	#
	var funnel = OscServer.incoming_messages.get("/mouthFunnel", [0])[0]
	$face.set_blend_shape_value(funnel_id, funnel)
	$faceL.set_blend_shape_value(funnel_id, funnel)
