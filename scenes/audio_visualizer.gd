# Adapted from https://github.com/dannyboy1044/GodotAudioVisualizerExample

extends Node2D

@export var audio_player: AudioStreamPlayer

var spectrum_instance
@export var NUM_BARS: int = 32  # Number of frequency bands to display
@export var MIN_FREQ: float = 0.0  # Frequency range to analyze
@export var MAX_FREQ: float = 1000.0  # Frequency range to analyze
@export var bar_scale: float = 500
@export var bar_envelope: Curve
@export var max_height: float = 64
var bars = []
var magnitudes = []
@export var color_gradient: Gradient


func _ready():
	spectrum_instance = AudioServer.get_bus_effect_instance(1, 1)  # Bus 1, Effect 0
	create_bars()
	audio_player.play()

func create_bars():
	for i in range(NUM_BARS):
		var bar = ColorRect.new()
		bar.color = color_gradient.sample(0)
		bar.size = Vector2(1, 32)  # Adjust bar size
		bar.position = Vector2(i*1, 0)  # Space bars apart
		bar.scale.y = -1
		bar.z_index = -1
		var bar_mirror = bar.duplicate()
		bar_mirror.position.x *= -1
		bar_mirror.position.x -= bar.size.x
		$BarRoot.add_child(bar)
		$BarRoot.add_child(bar_mirror)
		bars.push_back([bar, bar_mirror])
		
		magnitudes.push_back(0.0)
	
	bars.reverse()

func _process(_delta):
	if not spectrum_instance:
		return
	var max_freq_amp = magnitudes.reduce(max)
	
	for i in range(NUM_BARS):
		var freq_start = lerp(MIN_FREQ, MAX_FREQ, float(i) / float(NUM_BARS))
		@warning_ignore("integer_division")
		var freq_end = lerp(MIN_FREQ, MAX_FREQ, float(i + 1) / float(NUM_BARS))
		
		var magnitude = spectrum_instance.get_magnitude_for_frequency_range(freq_start, freq_end).length()
		magnitudes[i] = magnitude
		var size_y = magnitude * bar_scale
		size_y *= bar_envelope.sample(float(i)/float(NUM_BARS))
		size_y = lerp(bars[i][0].size.y, size_y, 0.2)  # Smooth animation
		size_y = clamp(size_y, 0.0, max_height)
		bars[i][0].size.y = size_y
		bars[i][0].position.y = -8 + (size_y / 4)
		bars[i][1].size.y = size_y
		bars[i][1].position.y = -8 + (size_y / 4)
		
		var intensity = (magnitude) / (max_freq_amp) if max_freq_amp > 0 else 0.0
		intensity = clamp(intensity, 0.0, 1.0)  # Keep within valid range

		# Get dynamic color from gradient
		var bar_color = color_gradient.sample(intensity)
		bars[i][0].color = bar_color
		bars[i][1].color = bar_color
