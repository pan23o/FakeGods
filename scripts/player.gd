extends Node2D
## Movimiento, ataque dirigido y salud del jugador.

signal health_changed(current: int, maximum: int)
signal died

const MOVE_SPEED := 235.0
const ATTACK_RANGE := 76.0
const ATTACK_DAMAGE := 34
const ATTACK_COOLDOWN := 0.34
const HURT_COOLDOWN := 0.72

var maximum_health: int = 100
var health: int = 100
var facing := Vector2.RIGHT
var attack_timer := 0.0
var hurt_timer := 0.0
var attack_flash := 0.0
var enabled := true


func configure(max_health: int) -> void:
	maximum_health = max_health
	health = max_health


func _process(delta: float) -> void:
	attack_timer = maxf(0.0, attack_timer - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	if not enabled:
		queue_redraw()
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length_squared() > 0.0:
		facing = direction.normalized()
		var half_view := get_viewport_rect().size * 0.5
		position += direction.normalized() * MOVE_SPEED * delta
		position.x = clampf(position.x, 60.0, half_view.x * 2.0 - 60.0)
		position.y = clampf(position.y, 125.0, half_view.y * 2.0 - 52.0)

	if (Input.is_action_just_pressed("attack") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and attack_timer <= 0.0:
		attack()
	queue_redraw()


func attack() -> void:
	attack_timer = ATTACK_COOLDOWN
	attack_flash = 0.13
	var closest: Node2D = null
	var closest_distance := ATTACK_RANGE
	for target in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(target) or not target.has_method("take_damage"):
			continue
		var offset: Vector2 = target.global_position - global_position
		var distance := offset.length()
		if distance <= closest_distance and (distance < 26.0 or facing.dot(offset.normalized()) >= 0.25):
			closest = target
			closest_distance = distance
	if closest != null:
		closest.take_damage(ATTACK_DAMAGE)


func take_damage(amount: int) -> void:
	if not enabled or hurt_timer > 0.0:
		return
	hurt_timer = HURT_COOLDOWN
	health = maxi(0, health - amount)
	health_changed.emit(health, maximum_health)
	if health <= 0:
		enabled = false
		died.emit()


func _draw() -> void:
	var body_color := Color("f0c987") if hurt_timer <= 0.0 else Color("ff8585")
	draw_circle(Vector2(0, 4), 18, Color(0, 0, 0, 0.22))
	draw_circle(Vector2.ZERO, 15, body_color)
	draw_circle(Vector2(0, -3), 7, Color("fff0c8"))
	draw_line(Vector2.ZERO, facing * 25, Color("8ce7dc"), 5.0, true)
	if attack_flash > 0.0:
		var arc_center := facing * 28.0
		draw_arc(arc_center, ATTACK_RANGE * 0.65, facing.angle() - 0.9, facing.angle() + 0.9, 20, Color("a8fff0"), 4.0, true)
