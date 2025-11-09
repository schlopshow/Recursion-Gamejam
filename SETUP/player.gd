extends CharacterBody2D

@export var jump_height = 60.0
@export var jump_time_to_peak = 0.5
@export var jump_time_to_descent = 0.4

@export var speed = 150.0
@export var friction = 1500.0

@export var throw_force = 300.0

@export var dash_speed_x := 300.0
@export var dash_speed_y := 300.0
@export var dash_duration := 0.2  # seconds

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var facing_direction = Vector2.RIGHT

var dash_timer := 0.0
var is_dashing := false
var used_dash := false
var dash_direction := Vector2.ZERO

var should_turn = false
var transitioning = false
var crouching = false

func do_movement(delta):
	var move_dir = Vector2.ZERO

	if Input.is_action_pressed("right"):
		move_dir.x += 1
	if Input.is_action_pressed("left"):
		move_dir.x -= 1
	if Input.is_action_pressed("down"):
		move_dir.y += 1
	if Input.is_action_pressed("up"):
		move_dir.y -= 1
	
	if move_dir.x == 0 and abs(velocity.x) > friction * delta:
		velocity.x -= velocity.x * (friction * delta) / speed
	else:
		velocity.x = move_dir.x * speed
		
	if move_dir.x == 0:
		move_dir.x = facing_direction.x
		
	facing_direction = move_dir.normalized()
	
func get_custom_gravity():
	if velocity.y < 0.0 :
		return -2.0 * jump_height / pow(jump_time_to_peak, 2)
	else:
		return -2.0 * jump_height / pow(jump_time_to_descent, 2)

func check_tilemap_collisions():
	var last_slide_collision = get_last_slide_collision()
	if last_slide_collision:
		var tilemap = last_slide_collision.get_collider()	
		

#func throw_head():
	#if not current_head:
		#current_head = head_scene.instantiate()
		#get_parent().add_child(current_head)
		#
	#current_head.global_position = global_position + facing_direction * 10
	#current_head.velocity = facing_direction * current_head.speed
	
func start_dash():
	is_dashing = true
	used_dash = true
	dash_timer = dash_duration
	dash_direction = facing_direction.normalized()
	velocity.x = dash_direction.x * dash_speed_x
	#velocity.y = dash_direction.y * dash_speed_y
	velocity.y = 0

func _physics_process(delta):
	if transitioning:
		return
	
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction.x * dash_speed_x
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			is_dashing = false
			velocity = Vector2.ZERO
			
		if dash_timer <= 0.0:
			is_dashing = false
		
	else:
		do_movement(delta)
		velocity.y += get_custom_gravity() * -1 * delta
		
		velocity.y = min(velocity.y, 350)
		move_and_slide()
	
	if is_on_floor() && Input.is_action_pressed("up"):
		velocity.y = 2.0 * jump_height / jump_time_to_peak * -1
	
	if is_on_floor():
		used_dash = false
		
	_update_animation()

	
func _update_animation():
	
	if facing_direction.y > 0:
		anim.play("crouch")
		return
	
	if is_on_floor():
		if velocity == Vector2.ZERO:
			anim.play("idle")
			should_turn = false
			return
		var new_flip = facing_direction.x < 0
		if new_flip != anim.flip_h:
			if should_turn:
				_play_turn_animation()
				return
			anim.flip_h = new_flip
		anim.play("run")
		should_turn = true
		return

	
		
	if velocity.y < 0:
		anim.play("jump")
		should_turn = false
		return
		
	if velocity.y > 0:
		anim.play("fall")
		should_turn = false
		return
		
		
func _play_turn_animation():
	transitioning = true
	anim.play("turn_around")
	
	print_debug("playing")
	

func _on_animated_sprite_2d_animation_finished():
	print_debug("finish called")
	if anim.animation == "turn_around":
		anim.flip_h = !anim.flip_h
		anim.play("run")
		transitioning = false # Replace with function body.
		print_debug("ended")
