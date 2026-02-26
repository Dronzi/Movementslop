extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -450.0
const  DASH_SPEED = 650.0
var dashing = false
var can_dash = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if velocity.y > 0:
		velocity += get_gravity() * delta * 1.15
	
	# Handle Jump, Coyote Time, and Jump Buffering
	if is_on_floor():
		$CoyoteTimer.start()
	if not $CoyoteTimer.is_stopped() and Input.is_action_just_pressed("Jump"):
		velocity.y = JUMP_VELOCITY
		$CoyoteTimer.stop()
		
		
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 6
		
	if not is_on_floor() and Input.is_action_just_pressed("Jump"):
		$BufferedJump.start()
	if is_on_floor() and not $BufferedJump.is_stopped():
		velocity.y = JUMP_VELOCITY
		
	# Roll Jumping
	if dashing and Input.is_action_just_pressed("Jump"):
		velocity.y = JUMP_VELOCITY
		velocity.x = DASH_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("Move_Left", "Move_Right")
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, 70) #acceleration
	else:
		velocity.x = move_toward(velocity.x, 0, 20) #momemtum
	
	# Dash
	if is_on_floor() and can_dash and Input.is_action_just_pressed("Roll") and direction:
		dashing = true
		can_dash = false
		$RollTimer.start()
		$RollAgainTimer.start()
	
	move_and_slide()
	
# Stop dashing
func _on_timer_timeout() -> void:
	dashing = false
func _on_roll_again_timer_timeout() -> void:
	can_dash = true
