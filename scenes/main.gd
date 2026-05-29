extends Node

## Entry point: creates the main menu.

func _ready() -> void:
	GameManager.state = GameManager.GameState.MENU
	var menu := CanvasLayer.new()
	menu.name = "MainMenu"
	menu.set_script(load("res://ui/main_menu/main_menu.gd"))
	add_child(menu)

	# Achievement toast (persists across scenes)
	var toast := CanvasLayer.new()
	toast.name = "AchievementToast"
	toast.set_script(load("res://ui/achievement_toast.gd"))
	add_child(toast)
