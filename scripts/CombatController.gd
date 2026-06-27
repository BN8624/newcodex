# 자동 전투 타이머와 공격 판정을 실행하는 컨트롤러
extends Node
class_name CombatController

signal enemy_hit(amount, critical)
signal player_hit(amount)
signal enemy_defeated(result)
signal boss_cleared(result)
signal player_down()
signal enemy_spawned()

var state
var player_timer := 0.0
var enemy_timer := 0.0
var enemy_interval := 1.25


func start(new_state) -> void:
	state = new_state
	player_timer = 0.0
	enemy_timer = 0.0
	set_process(true)
	enemy_spawned.emit()


func _process(delta: float) -> void:
	if state == null:
		return

	var stats: Dictionary = state.get_player_stats()
	player_timer += delta
	enemy_timer += delta

	if player_timer >= float(stats["attack_interval"]):
		player_timer = 0.0
		var roll: Dictionary = state.roll_player_damage()
		var result: Dictionary = state.damage_enemy(int(roll["damage"]))
		enemy_hit.emit(int(roll["damage"]), bool(roll["critical"]))
		if bool(result.get("defeated", false)):
			enemy_defeated.emit(result)
			if bool(result.get("boss_clear", false)):
				boss_cleared.emit(result)
			enemy_spawned.emit()

	if enemy_timer >= enemy_interval:
		enemy_timer = 0.0
		var hit: Dictionary = state.enemy_attack_player()
		var damage := int(hit["damage"])
		if damage > 0:
			player_hit.emit(damage)
		if bool(hit["player_down"]):
			player_down.emit()
