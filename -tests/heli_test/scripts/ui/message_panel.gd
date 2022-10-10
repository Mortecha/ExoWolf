# message_panel.gd
#
# This code is part of Thalassikopter. Copyright (C) 2021-2022 waimus
# https://gitlab.com/waimus/thalassikopter
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Label


onready var timer : Timer = get_node("Timer")
var display_time : float = 3
var message : String = "[INFO] default message . . . "
var colour : Color = Color.white


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_self_modulate(colour)
	self.set_text(message)
	timer.start(display_time)


func _on_timer_timeout() -> void:
	self.queue_free()
