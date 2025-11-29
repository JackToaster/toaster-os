extends Control

var overlay_toggle_group = ButtonGroup.new()

func _ready() -> void:
	overlay_toggle_group.allow_unpress = true
	for child in $ButtonContainer.get_children():
		if child.is_in_group("OverlayToggle"):
			var child_btn: CheckButton = child
			child_btn.button_group = overlay_toggle_group
			child_btn.toggled.connect(_overlay_toggled)
	visibility_changed.connect(_update_brightness_slider)

func _update_brightness_slider():
	# make brightness slider initialize correctly
	var brightness = 1.0 - %HeadRender/Attenuate.color.a
	$ButtonContainer/BrightnessContainer/HSlider.value = brightness
	

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


var badapple = preload("res://scenes/badapple.tscn")
var badapple_inst = null
func _on_bad_apple_toggled(toggled_on: bool) -> void:
	if toggled_on:
		badapple_inst = badapple.instantiate()
		%HeadRender.add_child(badapple_inst)
	else:
		if badapple_inst != null:
			badapple_inst.queue_free()


# WIP Doom stuff - needs an ARM64 build of godot-wasm, can't be bothered now.
#
#var doom = preload("res://scenes/doom.tscn")
#var doom_inst = null
#func _on_doom_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#doom_inst = doom.instantiate()
		#%HeadRender.add_child(doom_inst)
	#else:
		#if doom_inst != null:
			#doom_inst.queue_free()

var blackhole_eye = preload("res://scenes/blackhole.tscn")
var blackhole_eye_inst = null
func _on_blackhole_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%"HeadRender/Head/Content/pretzelgen-face-render-model".set_eye_visible(false)
		blackhole_eye_inst = blackhole_eye.instantiate()
		%HeadRender.add_child(blackhole_eye_inst)
	else:
		%"HeadRender/Head/Content/pretzelgen-face-render-model".set_eye_visible(true)
		if blackhole_eye_inst != null:
			blackhole_eye_inst.queue_free()


func _on_dimmer_pressed() -> void:
	var brightness = 1.0 - %HeadRender/Attenuate.color.a
	brightness *= 0.66
	$ButtonContainer/BrightnessContainer/HSlider.value = brightness
	var alpha = 1.0 - brightness
	%HeadRender/Attenuate.color.a = alpha

func _on_brighter_pressed() -> void:
	var brightness = 1.0 - %HeadRender/Attenuate.color.a
	brightness *= 1.5
	if brightness > 1.0:
		brightness = 1.0
	$ButtonContainer/BrightnessContainer/HSlider.value = brightness
	var alpha = 1.0 - brightness
	%HeadRender/Attenuate.color.a = alpha
