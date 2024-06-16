extends State
class_name PlayerIdle

@onready var player = CharacterBody2D
@onready var animated_sprite_2d = AnimatedSprite2D

var patience_time: int = 2
var time_since_last_move: float = 0

func Enter():
	pass
	
func Exit():
	pass

func Update(delta: float):
	time_since_last_move += delta
	if time_since_last_move > patience_time:
		animated_sprite_2d.play('smoke')
