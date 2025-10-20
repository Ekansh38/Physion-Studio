extends Resource
class_name PhysicsSettings

# Global physics environment settings that affect all balls

@export var gravity: Vector2 = Vector2(0, 980) # pixels per second squared
@export var floor_friction: float = 0.0
@export var sensitivity: float = 0.8    # how much velocity is applied when thrown
@export var max_throw_velocity: float = 3000.0  # maximum velocity when throwing with mouse
@export var max_velocity: float = 5000.0  # maximum velocity for the ball overall
@export var energy_loss: float = 0.1  # energy lost in collisions (0.0 = perfectly elastic, 1.0 = no bounce)
@export var air_resistance: float = 0.0002  # air resistance coefficient (0.0 = no resistance, higher = more resistance)
@export var velocity_threshold: float = 10.0  # velocity below this becomes zero to prevent jittering