extends Control

@export
var step_size: float = 0.01

class RoiSide:
	var value
	var step
	func _init(_value, _step):
		value = _value
		step = _step
	func increment():
		value += step
		value = clamp(value, 0, 1)
	func decrement():
		value -= step
		value = clamp(value, 0, 1)

class Roi:
	var top: RoiSide
	var bottom: RoiSide
	var left: RoiSide
	var right: RoiSide
	var osc_address: String
	var roi_ref: ReferenceRect
	func _init(_top, _bottom, _left, _right, _step, _osc_address, _roi_ref):
		top = RoiSide.new(_top, -_step)
		bottom = RoiSide.new(_bottom, _step)
		left = RoiSide.new(_left, -_step)
		right = RoiSide.new(_right, _step)
		osc_address = _osc_address
		roi_ref = _roi_ref
	
	func send():
		OscClient.send_message(osc_address, [left.value,top.value,right.value,bottom.value])
		var x_scale = right.value - left.value
		var x_offs = left.value
		
		var y_scale = bottom.value - top.value
		var y_offs = top.value
		
		var img_ref_size = roi_ref.get_parent().size
		roi_ref.set_size(Vector2(x_scale, y_scale) * img_ref_size)
		roi_ref.set_position(Vector2(x_offs, y_offs) * img_ref_size)

#@onready var top = RoiSide.new(0.3, -step_size)
#@onready var bottom = RoiSide.new(1.0, step_size)
#@onready var left = RoiSide.new(0.0, -step_size)
#@onready var right = RoiSide.new(1.0, step_size)

@onready var mouth = Roi.new(0.3, 1.0, 0.0, 1.0, step_size, "/roi/mouth", $"adjust frame/ImageRef/MouthRoiRef")
@onready var left_eye = Roi.new(0.0, 0.25, 0.0, 0.4, step_size, "/roi/eye/left", $"adjust frame/ImageRef/LeftEyeRoiRef")
@onready var right_eye = Roi.new(0.0, 0.25, 0.6, 1.0, step_size, "/roi/eye/right", $"adjust frame/ImageRef/RightEyeRoiRef")


func connect_plus_minus_buttons(btn: Control, plus, minus):
	var plus_btn: Button = btn.get_node("Plus")
	var minus_btn: Button = btn.get_node("Minus")
	
	plus_btn.pressed.connect(plus)
	minus_btn.pressed.connect(minus)




func selected_roi() -> Roi:
	if $Selector/Mouth.button_pressed:
		return mouth
	elif $"Selector/Left Eye".button_pressed:
		return left_eye
	elif $"Selector/Right Eye".button_pressed:
		return right_eye
	
	print("Invalid ROI selection!")
	return mouth

# ----- Button functions -----
func inc_top():
	selected_roi().top.increment()
	selected_roi().send()
func dec_top():
	selected_roi().top.decrement()
	selected_roi().send()
func inc_bottom():
	selected_roi().bottom.increment()
	selected_roi().send()
func dec_bottom():
	selected_roi().bottom.decrement()
	selected_roi().send()
func inc_left():
	selected_roi().left.increment()
	selected_roi().send()
func dec_left():
	selected_roi().left.decrement()
	selected_roi().send()
func inc_right():
	selected_roi().right.increment()
	selected_roi().send()
func dec_right():
	selected_roi().right.decrement()
	selected_roi().send()

func update_highlight(_btn=null):
	print("update highlight")
	mouth.roi_ref.border_color = Color.CORNFLOWER_BLUE
	left_eye.roi_ref.border_color = Color.CORNFLOWER_BLUE
	right_eye.roi_ref.border_color = Color.CORNFLOWER_BLUE
	selected_roi().roi_ref.border_color = Color.SPRING_GREEN

var selector_btn_group = ButtonGroup.new()

func _ready() -> void:
	# Create button group for radio buttons
	$Selector/Mouth.button_group = selector_btn_group
	$"Selector/Left Eye".button_group = selector_btn_group
	$"Selector/Right Eye".button_group = selector_btn_group
	# Update highlighted ROI rect on selection change
	selector_btn_group.pressed.connect(update_highlight)
	
	# Connect adjustor buttons
	connect_plus_minus_buttons($"adjust frame/Top", inc_top, dec_top)
	connect_plus_minus_buttons($"adjust frame/Bottom", inc_bottom, dec_bottom)
	connect_plus_minus_buttons($"adjust frame/Left", inc_left, dec_left)
	connect_plus_minus_buttons($"adjust frame/Right", inc_right, dec_right)
	
	# Update colors for initial selection
	update_highlight()
	
	# TODO Make this run when the tracking script starts up rather than on _ready
	mouth.send()
	left_eye.send()
	right_eye.send()
