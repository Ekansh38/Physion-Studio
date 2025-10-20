extends Node2D
class_name BallParent


# the b_ stands for ball_
# this is to keep my variables seperate

var b_position: Vector2
var b_velocity: Vector2
var b_acceleration: Vector2
var is_dragged: bool = false
var mouse_positions := []

var near_balls := []
var collision_cooldowns := {}  # Track collision cooldowns to prevent repeated collisions

# Ball-specific properties (individual to each ball)
@export var b_mass: float = 1.0
@export var radius: float = 59.5
@export var restitution: float = 0.5   # elasticity

func _ready() -> void:
	b_position = position 

func _physics_process(delta: float) -> void: # FIXME: split into separate functions
	# Integrate
	b_acceleration = PhysicsManager.get_gravity()
	b_velocity += b_acceleration * delta
	
	# Apply air resistance (only when not dragged)
	if not is_dragged:
		var air_drag = b_velocity * PhysicsManager.get_air_resistance() * b_velocity.length()  # quadratic air resistance
		b_velocity -= air_drag * delta
	
	# Dampen very small velocities to zero (but only if not dragged and not on floor)
	var is_on_floor = b_position.y >= (get_viewport_rect().size.y - radius - 1.0)
	if not is_dragged and not is_on_floor and b_velocity.length() < PhysicsManager.get_velocity_threshold():
		b_velocity = Vector2.ZERO
	
	# Cap velocity to maximum speed
	if b_velocity.length() > PhysicsManager.get_max_velocity():
		b_velocity = b_velocity.normalized() * PhysicsManager.get_max_velocity()
	
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
			# Only apply friction if horizontal velocity is significant
			if abs(b_velocity.x) > 1.0:
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
				
				# Cap the velocity to max_throw_velocity
				if b_velocity.length() > max_throw_velocity:
					b_velocity = b_velocity.normalized() * max_throw_velocity
			else:
				b_velocity = Vector2.ZERO
			# Clear stored mouse positions
			mouse_positions.clear()
	
	# Update collision cooldowns
	for ball in collision_cooldowns.keys():
		collision_cooldowns[ball] -= delta
		if collision_cooldowns[ball] <= 0:
			collision_cooldowns.erase(ball)
	
	for ball in near_balls:
		# Skip if we're in cooldown with this ball
		if collision_cooldowns.has(ball):
			continue
			
		var to_ball: Vector2 = ball.b_position - b_position
		var dist: float = to_ball.length()
		var min_dist: float = radius + ball.radius
		
		if dist < min_dist and dist > 0.1:  # Avoid division by zero
			# Separate the balls first
			var overlap: float = min_dist - dist
			var separation: Vector2 = to_ball.normalized() * (overlap * 0.5)
			
			# Only move if not dragged
			if not is_dragged:
				b_position -= separation
			if not ball.is_dragged:
				ball.b_position += separation

			# Calculate collision response using proper elastic collision formula
			var normal: Vector2 = to_ball.normalized()
			var relative_velocity: Vector2 = ball.b_velocity - b_velocity
			var velocity_along_normal: float = relative_velocity.dot(normal)
			
			# Don't resolve if velocities are separating
			if velocity_along_normal > 0:
				continue
				
			# Calculate effective restitution with energy loss
			var effective_restitution: float = min(restitution, ball.restitution) * (1.0 - energy_loss)
			var j: float = -(1 + effective_restitution) * velocity_along_normal
			j /= (1.0 / b_mass + 1.0 / ball.b_mass)
			
			# Apply impulse
			var impulse: Vector2 = j * normal
			if not is_dragged:
				b_velocity -= impulse / b_mass
			if not ball.is_dragged:
				ball.b_velocity += impulse / ball.b_mass
			
			# Add collision cooldown to prevent repeated collisions
			collision_cooldowns[ball] = 0.05  # 0.05 second cooldown
			ball.collision_cooldowns[self] = 0.05






	if is_dragged:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		
		# Calculate velocity based on mouse movement while dragging
		if mouse_positions.size() >= 1:
			var last_mouse_pos: Vector2 = mouse_positions[mouse_positions.size() - 1]
			b_velocity = (mouse_pos - last_mouse_pos) / delta
		else:
			b_velocity = Vector2.ZERO
		
		position = mouse_pos
		b_position = mouse_pos
		# Store mouse positions for velocity calculation
		mouse_positions.append(mouse_pos)
		if mouse_positions.size() > 2:
			mouse_positions.pop_front()
	else:
		position = b_position



func _on_other_ball_entered(area: Area2D) -> void:
	var area_parent = area.get_parent()
	if area_parent is BallParent and area_parent != self:
		near_balls.append(area_parent)

func _on_other_ball_exited(area: Area2D) -> void:
	var area_parent = area.get_parent()
	if area_parent is BallParent and area_parent != self:
		near_balls.erase(area_parent)
