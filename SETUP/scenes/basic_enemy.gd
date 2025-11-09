extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	pass
	
	

func take_damage(direction):
	print_debug("hit, go", direction)
	
	
