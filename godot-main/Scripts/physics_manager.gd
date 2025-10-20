extends Node

# Global physics manager
# This manages physics settings that apply to all balls in the simulation

var physics_settings: Resource

func _ready() -> void:
	# Load or create physics settings
	var settings_path = "res://physics_settings.tres"
	
	if ResourceLoader.exists(settings_path):
		physics_settings = load(settings_path)
	else:
		# Create default settings
		var physics_settings_script = load("res://Scripts/physics_settings.gd")
		physics_settings = physics_settings_script.new()
		# Save default settings
		ResourceSaver.save(physics_settings, settings_path)
	
	print("Physics settings loaded")

# Convenience functions to access settings
func get_gravity() -> Vector2:
	return physics_settings.gravity

func get_air_resistance() -> float:
	return physics_settings.air_resistance

func get_max_velocity() -> float:
	return physics_settings.max_velocity

func get_energy_loss() -> float:
	return physics_settings.energy_loss

func get_sensitivity() -> float:
	return physics_settings.sensitivity

func get_max_throw_velocity() -> float:
	return physics_settings.max_throw_velocity

func get_floor_friction() -> float:
	return physics_settings.floor_friction

func get_velocity_threshold() -> float:
	return physics_settings.velocity_threshold

# Function to save settings (if settings are modified at runtime)
func save_settings() -> void:
	ResourceSaver.save(physics_settings, "res://physics_settings.tres")