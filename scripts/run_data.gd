extends Node
## Datos persistentes entre ascensiones: esencia y mejora permanente de salud.

const SAVE_PATH := "user://fakegods_save.json"
const UPGRADE_COST := 3
const HEALTH_PER_UPGRADE := 15

var essence: int = 0
var health_upgrades: int = 0


func _ready() -> void:
	_load_save()


func max_health() -> int:
	return 100 + health_upgrades * HEALTH_PER_UPGRADE


func add_essence(amount: int) -> void:
	if amount <= 0:
		return
	essence += amount
	_save()


func buy_health_upgrade() -> bool:
	if essence < UPGRADE_COST:
		return false
	essence -= UPGRADE_COST
	health_upgrades += 1
	_save()
	return true


func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		essence = maxi(0, int(parsed.get("essence", 0)))
		health_upgrades = maxi(0, int(parsed.get("health_upgrades", 0)))


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("No se pudo guardar la progresión en " + SAVE_PATH)
		return
	file.store_string(JSON.stringify({
		"essence": essence,
		"health_upgrades": health_upgrades,
	}))
