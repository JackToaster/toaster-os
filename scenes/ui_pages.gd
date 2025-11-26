extends Control

var pages := []        # Array to store page nodes
var current_page := 0  # Index of active page

func _ready():
	# Get all direct children that are Control nodes (your pages)
	for child in get_children():
		if child is Control:
			pages.append(child)
	
	# Hide all pages except the first one
	_update_pages()


func _update_pages():
	for i in range(pages.size()):
		pages[i].visible = (i == current_page)


func _on_next_btn_pressed():
	current_page = (current_page + 1) % pages.size()
	_update_pages()


func _on_prev_btn_pressed():
	current_page = (current_page - 1 + pages.size()) % pages.size()
	_update_pages()
