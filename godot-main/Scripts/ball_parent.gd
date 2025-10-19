extends Node2D


# the b_ stands for ball_
# this is to keep my variables seperate

var b_position: Vector2
var b_velocity: Vector2
var b_acceleration: Vector2
var is_dragged: bool = false
var mouse_positions := []

@export var gravity: Vector2 = Vector2(0, 980) # pixels per second squared
@export var b_mass: float = 1.0

@export var radius: float = 59.5
@export var restitution: float = 0.5   # elasticity
@export var floor_friction: float = 0.0
@export var sensitivity: float = 0.8    # how much velocity is applied when thrown

func _ready() -> void:
	b_position = position 

func _physics_process(delta: float) -> void: # FIXME: split into separate functions
	# Integrate
	b_acceleration = gravity
	b_velocity += b_acceleration * delta
	# Dampen very small velocities to zero (very important LOLLL)
	if b_velocity.length() < 0.02:
		b_velocity = Vector2.ZERO
	b_position += b_velocity * delta

	# Collide with viewport bounds (treat b_position as CENTER)
	var screen_size: Vector2 = get_viewport_rect().size
	var left   := radius
	var right  := screen_size.x - radius
	var top    := radius
	var bottom := screen_size.y - radius

	# X
	if b_position.x < left:
		b_position.x = left
		if b_velocity.x < 0.0:
			b_velocity.x = -b_velocity.x * restitution
	elif b_position.x > right:
		b_position.x = right
		if b_velocity.x > 0.0:
			b_velocity.x = -b_velocity.x * restitution

	# Y
	if b_position.y < top:
		b_position.y = top
		if b_velocity.y < 0.0:
			b_velocity.y = -b_velocity.y * restitution
	elif b_position.y > bottom:
		b_position.y = bottom
		if b_velocity.y > 0.0:
			b_velocity.y = -b_velocity.y * restitution
			b_velocity.x *= (1.0 - floor_friction) 



	

	# Be throwable by the mouse

	if Input.is_action_just_pressed("click"):
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var to_mouse: Vector2 = mouse_pos - b_position

		if to_mouse.length() <= radius:
			# Clicked on the ball
			# Grab onto the mouse
			is_dragged = true

	if Input.is_action_just_released("click"):
		if is_dragged:
			# Release from the mouse
			is_dragged = false
			# Calculate velocity based on last mouse positions
			if mouse_positions.size() >= 2:
				var last_pos: Vector2 = mouse_positions[mouse_positions.size() - 1]
				var prev_pos: Vector2 = mouse_positions[mouse_positions.size() - 2]
				b_velocity = ((last_pos - prev_pos) / delta) * (1.0 / b_mass) * sensitivity
			# Clear stored mouse positions
			mouse_positions.clear()



	if is_dragged:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		b_position = mouse_pos
		# Store mouse positions for velocity calculation
		mouse_positions.append(mouse_pos)
		if mouse_positions.size() > 2:
			mouse_positions.pop_front()








	# Update position
	position = b_position
