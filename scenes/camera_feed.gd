extends Sprite2D

@export var camera_name: String = ""
var camera: CameraFeed

# Called when the node enters the scene tree for the first time.
func _ready():
	CameraServer.camera_feeds_updated.connect(_on_camera_feeds_updated)
	CameraServer.monitoring_feeds = true

func _on_camera_feeds_updated():
	# Defer processing to next frame to ensure monitoring is fully active
	call_deferred("_process_camera_feeds")

func _process_camera_feeds() -> void:
	if camera == null:
		print("cameras:")
	for feed in CameraServer.feeds():
		var feed_name = feed.get_name()
		if camera == null:
			print(feed_name)
		
		# if camera_name is left empty, use the first available camera
		if camera == null and (camera_name == "" or feed_name == camera_name):
			camera = feed
			print("using camera ", camera, " (", camera.get_name(), ")")
			print(camera.formats)
			camera.set_format(0, {'output':'grayscale'})
			
			print(camera.get_datatype())
			print(camera.get_name())

			camera.feed_is_active = true
			texture.camera_feed_id = camera.get_id()
			#var cam_tex_y = material.get_shader_parameter("camera_y")
			#var cam_tex_CbCr = material.get_shader_parameter("camera_CbCr")
			#
			#cam_tex_y.camera_feed_id = camera.get_id()
			#cam_tex_CbCr.camera_feed_id = camera.get_id()
			#
			#material.set_shader_parameter("camera_y", cam_tex_y)
			#material.set_shader_parameter("camera_CbCr", cam_tex_CbCr)


			
	if camera == null:
		print("no matching camera")
		return
		
	
