# in_game_menu.gd
#
# This code is part of Thalassikopter. Copyright (C) 2021-2022 waimus
# https://gitlab.com/waimus/thalassikopter
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Panel


var enable : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_visible(false)


func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		self.enable = !self.enable
		enable_menu(self.enable)


func _on_resume_pressed() -> void:
	enable_menu(false)


func _on_quit_pressed() -> void:
	get_tree().quit()


func enable_menu(visible : bool) -> void:
		self.enable = visible
		self.set_visible(self.enable)
		
		if enable:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_mouse_sensitivity_slider_value_changed(value):
	Globals.update_mouse_sensitivity(value)
