extends HBoxContainer

@onready var left: CheckButton = $VBoxContainer/Left
@onready var right: CheckButton = $VBoxContainer/Right
@onready var both: CheckButton = $Both

func _ready():
	left.toggled.connect(left_toggle)
	right.toggled.connect(right_toggle)
	both.toggled.connect(combined_toggle)
	
	$TextEdit.text_changed.connect(text_changed)

func left_toggle(on:bool):
	if on and right.button_pressed:
		both.set_pressed_no_signal(true)
	elif not on and not right.button_pressed:
		both.set_pressed_no_signal(false)
	
	%HeadRender/TextL.visible = on

func right_toggle(on:bool):
	if on and left.button_pressed:
		both.set_pressed_no_signal(true)
	elif not on and not left.button_pressed:
		both.set_pressed_no_signal(false)
	
	%HeadRender/TextR.visible = on
	
func combined_toggle(on:bool):
	left.set_pressed(on)
	right.set_pressed(on)

func text_changed():
	%HeadRender/TextL/Label.text = $TextEdit.text
	%HeadRender/TextR/Label.text = $TextEdit.text
