extends Node2D
## Bucle de juego: templo, primera arena de ascensión y regreso tras morir.

const PlayerScript := preload("res://scripts/player.gd")
const EnemyScript := preload("res://scripts/enemy.gd")
const WAVE_SIZE := 3

var player: Node2D
var enemies_left := 0
var mode := "temple"
var hud: Label
var hint: Label
var status: Label


func _ready() -> void:
	_ensure_input_actions()
	_build_hud()
	player = PlayerScript.new()
	player.name = "Player"
	player.configure(RunData.max_health())
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_player_died)
	add_child(player)
	player.position = get_viewport_rect().size * 0.5
	_update_hud()
	queue_redraw()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if mode == "temple":
			_start_ascent()
			_update_hud()
		elif mode == "combat" and enemies_left <= 0:
			_return_to_temple("Arena despejada. Has vuelto al templo.")
	if Input.is_action_just_pressed("upgrade") and mode == "temple":
		if RunData.buy_health_upgrade():
			player.configure(RunData.max_health())
			status.text = "Mejora permanente comprada: +15 de vida máxima."
		else:
			status.text = "Necesitas 3 de esencia para mejorar la vida."
	queue_redraw()


func _start_ascent() -> void:
	mode = "combat"
	status.text = "Primera ascensión · Arena 1 · derrota a los tres guardianes."
	player.enabled = true
	player.health = player.maximum_health
	player.position = Vector2(get_viewport_rect().size.x * 0.5, get_viewport_rect().size.y * 0.73)
	player.health_changed.emit(player.health, player.maximum_health)
	enemies_left = WAVE_SIZE
	for index in WAVE_SIZE:
		_spawn_enemy(index)
	_update_hud()


func _spawn_enemy(index: int) -> void:
	var enemy: Node2D = EnemyScript.new()
	enemy.name = "Guardian_%d" % (index + 1)
	var positions := [Vector2(270, 220), Vector2(690, 215), Vector2(480, 155)]
	enemy.position = positions[index]
	enemy.set_target(player)
	enemy.defeated.connect(_on_enemy_defeated)
	add_child(enemy)


func _on_enemy_defeated(_enemy: Node2D) -> void:
	if mode != "combat":
		return
	RunData.add_essence(1)
	enemies_left = maxi(0, enemies_left - 1)
	status.text = "Guardian derrotado. Esencia obtenida: 1."
	_update_hud()
	if enemies_left == 0:
		status.text = "Arena despejada. Pulsa E para volver al templo."


func _on_player_died() -> void:
	_return_to_temple("Has caído. La esencia conseguida se conserva; ya estás de vuelta en el templo.")


func _return_to_temple(message: String) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	mode = "temple"
	enemies_left = 0
	player.enabled = true
	player.health = player.maximum_health
	player.position = get_viewport_rect().size * 0.5
	player.health_changed.emit(player.health, player.maximum_health)
	status.text = message
	_update_hud()


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(22, 16)
	hud.add_theme_font_size_override("font_size", 18)
	hud.add_theme_color_override("font_color", Color("f4ead6"))
	layer.add_child(hud)
	status = Label.new()
	status.position = Vector2(22, 49)
	status.add_theme_font_size_override("font_size", 15)
	status.add_theme_color_override("font_color", Color("b9c7d5"))
	layer.add_child(status)
	hint = Label.new()
	hint.position = Vector2(22, 497)
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color("8fa4b8"))
	layer.add_child(hint)


func _update_hud() -> void:
	if hud == null:
		return
	hud.text = "VIDA %d/%d     ESENCIA %d     MEJORAS %d" % [player.health if player != null else RunData.max_health(), RunData.max_health(), RunData.essence, RunData.health_upgrades]
	if mode == "temple":
		hint.text = "WASD/flechas mover  ·  Espacio/clic atacar  ·  E ascender (%d guardianes)  ·  U mejorar vida (%d esencia)  ·  Esc salir" % [WAVE_SIZE, RunData.UPGRADE_COST]
	else:
		hint.text = "WASD/flechas mover  ·  Espacio/clic atacar  ·  E volver al templo al despejar la arena  ·  Esc salir"


func _on_health_changed(_current: int, _maximum: int) -> void:
	_update_hud()


func _ensure_input_actions() -> void:
	_add_key_action("move_left", KEY_A, KEY_LEFT)
	_add_key_action("move_right", KEY_D, KEY_RIGHT)
	_add_key_action("move_up", KEY_W, KEY_UP)
	_add_key_action("move_down", KEY_S, KEY_DOWN)
	_add_key_action("interact", KEY_E)
	_add_key_action("upgrade", KEY_U)
	_add_key_action("attack", KEY_SPACE)
	_add_key_action("ui_cancel", KEY_ESCAPE)


func _add_key_action(action: StringName, first_key: Key, second_key: Key = KEY_NONE) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var first := InputEventKey.new()
	first.physical_keycode = first_key
	InputMap.action_add_event(action, first)
	if second_key != KEY_NONE:
		var second := InputEventKey.new()
		second.physical_keycode = second_key
		InputMap.action_add_event(action, second)


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("101522"))
	if mode == "temple":
		_draw_temple(size)
	else:
		_draw_arena(size)


func _draw_temple(size: Vector2) -> void:
	var center := size * 0.5
	for ring in 4:
		draw_arc(center, 72.0 + ring * 29.0, 0.0, TAU, 80, Color(0.37, 0.68, 0.68, 0.23 - ring * 0.035), 2.0, true)
	draw_rect(Rect2(center + Vector2(-145, -122), Vector2(290, 244)), Color("1c2838"), false, 3.0)
	draw_line(center + Vector2(-145, 74), center + Vector2(145, 74), Color("647e89"), 2.0)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-95, -95), center + Vector2(0, -161), center + Vector2(95, -95),
	]), Color("40566a"))
	for x in [-112.0, 112.0]:
		draw_rect(Rect2(center + Vector2(x - 10, -97), Vector2(20, 174)), Color("34475b"))
	draw_string(ThemeDB.fallback_font, center + Vector2(-39, -35), "TEMPLO", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d9caa5"))
	draw_string(ThemeDB.fallback_font, Vector2(0, 115), "Una chispa antigua sigue ardiendo", HORIZONTAL_ALIGNMENT_CENTER, size.x, 15, Color("91a7b5"))


func _draw_arena(size: Vector2) -> void:
	draw_rect(Rect2(Vector2(56, 115), size - Vector2(112, 167)), Color("182230"), false, 3.0)
	for x in range(100, int(size.x - 50), 64):
		draw_line(Vector2(x, 116), Vector2(x, size.y - 52), Color(0.36, 0.48, 0.54, 0.13), 1.0)
	for y in range(145, int(size.y - 45), 64):
		draw_line(Vector2(57, y), Vector2(size.x - 57, y), Color(0.36, 0.48, 0.54, 0.13), 1.0)
	draw_arc(Vector2(size.x * 0.5, size.y * 0.49), 108, 0, TAU, 80, Color(0.38, 0.69, 0.7, 0.19), 2.0, true)
