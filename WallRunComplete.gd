extends KinematicBody

var speed = 7
var acceleration = 50
var gravity = 0.1
var no_grav = 0
var jump = 12

var damage = 100

var mouse_sensitivity = 0.03

var wall_normal
var w_runnable = false

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3() 

onready var head = $Head
onready var aimcast = $Head/Camera/AimCast
onready var timer = $Timer

func _ready():
	pass
	
func _input(event):
	
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity)) 
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity)) 
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))
		
func wall_run():
	if w_runnable:		
		if Input.is_action_pressed("jump"):	
			if Input.is_action_pressed("move_forward"):
				if is_on_wall():
					wall_normal = get_slide_collision(0)
					yield(get_tree().create_timer(0.2), "timeout")
					fall.y = 0
					direction = -wall_normal.normal * speed

func _physics_process(delta):
	
	wall_run()
	
	direction = Vector3()
	
	move_and_slide(fall, Vector3.UP)
	
	if not is_on_floor():
		fall.y -= gravity
	else:
		w_runnable = false
		
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			fall.y = jump
			w_runnable = true
			timer.start()
	
	if Input.is_action_pressed("move_forward"):
	
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("move_backward"):
		
		direction += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		
		direction -= transform.basis.x			
		
	elif Input.is_action_pressed("move_right"):
		
		direction += transform.basis.x
			
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta) 
	velocity = move_and_slide(velocity, Vector3.UP) 

func _on_Timer_timeout():
	w_runnable = false
