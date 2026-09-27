extends Node2D
## Enemigo sencillo que persigue al jugador y causa daño al tocarlo.

signal defeated(enemy: Node2D)

const MOVE_SPEED := 74.0
const TOUCH_DAMAGE := 12
const TOUCH_COOLDOWN := 0.95

var health := 68
var touch_timer := 0.0
var hit_flash := 0.0
var target: Node2D


func _ready() -> void:
	add_to_group("enemies")


func set_target(player: Node2D) -> void:
	target = player


func _process(delta: float) -> void:
	touch_timer = maxf(0.0, touch_timer - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	if is_instance_valid(target):
		var offset := target.global_position - global_position
		if offset.length() > 30.0:
			position += offset.normalized() * MOVE_SPEED * delta
		elif touch_timer <= 0.0 and target.has_method("take_damage"):
			touch_timer = TOUCH_COOLDOWN
			target.take_damage(TOUCH_DAMAGE)
	queue_redraw()


func take_damage(amount: int) -> void:
	health -= amount
	hit_flash = 0.12
	if health <= 0:
		defeated.emit(self)
		queue_free()
	queue_redraw()


func _draw() -> void:
	var color := Color("fff0d3") if hit_flash > 0.0 else Color("cb718c")
	draw_circle(Vector2(0, 4), 18, Color(0, 0, 0, 0.2))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -17), Vector2(16, -5), Vector2(12, 13),
		Vector2(0, 18), Vector2(-12, 13), Vector2(-16, -5),
	]), color)
	draw_circle(Vector2(-5, -2), 2.0, Color("fff6dc"))
	draw_circle(Vector2(5, -2), 2.0, Color("fff6dc"))
	var bar_width := 34.0
	draw_rect(Rect2(Vector2(-bar_width * 0.5, -27), Vector2(bar_width, 4)), Color("341f38"))
	draw_rect(Rect2(Vector2(-bar_width * 0.5, -27), Vector2(bar_width * clampf(float(health) / 68.0, 0.0, 1.0), 4)), Color("f18b9d"))
