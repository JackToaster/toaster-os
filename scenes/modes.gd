extends Control

var overlay_toggle_group = ButtonGroup.new()

func _ready() -> void:
	overlay_toggle_group.allow_unpress = true
	for child in $ButtonContainer.get_children():
		if child.is_in_group("OverlayToggle"):
			var child_btn: CheckButton = child
			child_btn.button_group = overlay_toggle_group
			child_btn.toggled.connect(_overlay_toggled)
	

func _on_face_toggled(toggled_on: bool) -> void:
	%"HeadRender/left-sprite".visible = toggled_on
	%"HeadRender/right-sprite".visible = toggled_on
	pass


var musicviz = preload("res://scenes/audio_visualizer.tscn")
var musicviz_inst = null
func _on_music_viz_toggled(toggled_on: bool) -> void:
	if toggled_on:
		musicviz_inst = musicviz.instantiate()
		%HeadRender.add_child(musicviz_inst)
	else:
		if musicviz_inst != null:
			musicviz_inst.queue_free()

func _overlay_toggled(toggled_on: bool):
	if toggled_on:
		var selected_overlay: OverlayToggle = overlay_toggle_group.get_pressed_button()
		%HeadRender/OverlayTex.texture = selected_overlay.overlay_texture
		%HeadRender/OverlayTex.visible = true
	else:
		%HeadRender/OverlayTex.visible = false
