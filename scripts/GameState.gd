# 플레이어 성장, 전투 진행도, 저장 가능한 상태를 관리하는 모델
extends RefCounted
class_name GameState

const GameDataClass := preload("res://data/game_data.gd")

var gold := 0
var player_level := 1
var exp := 0
var current_stage := 1
var current_enemy_progress := 0
var upgrade_levels := {}
var boss_clear_state := false
var last_play_time := 0
var settings := {"number_format": "short"}

var player_hp := 100.0
var enemy_hp := 1.0
var enemy_max_hp := 1.0
var enemy_data := {}
var is_boss := false

var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()
	reset(false)


func reset(update_time := true) -> void:
	gold = 0
	player_level = 1
	exp = 0
	current_stage = 1
	current_enemy_progress = 0
	upgrade_levels = {}
	for id in GameDataClass.get_upgrade_ids():
		upgrade_levels[id] = 0
	boss_clear_state = false
	settings = {"number_format": "short"}
	if update_time:
		last_play_time = Time.get_unix_time_from_system()
	restore_player()
	spawn_enemy()


func restore_player() -> void:
	player_hp = float(get_player_stats()["max_hp"])


func exp_to_next_level() -> int:
	return 24 + (player_level - 1) * 14


func get_player_stats() -> Dictionary:
	var attack_level := int(upgrade_levels.get("attack", 0))
	var hp_level := int(upgrade_levels.get("hp", 0))
	var defense_level := int(upgrade_levels.get("defense", 0))
	var speed_level := int(upgrade_levels.get("speed", 0))
	var gold_level := int(upgrade_levels.get("gold", 0))
	var crit_level := int(upgrade_levels.get("crit", 0))
	var attack := 12.0 + float(player_level - 1) * 2.5 + float(attack_level) * 5.0
	var max_hp := 110 + (player_level - 1) * 10 + hp_level * 24
	var defense := defense_level * 2
	var attack_interval: float = max(0.36, 1.05 - float(speed_level) * 0.035)
	var gold_multiplier := 1.0 + float(gold_level) * 0.1
	var crit_chance: float = min(0.42, 0.08 + float(crit_level) * 0.018)
	var power := int(round(attack * 9.0 + float(max_hp) + float(defense) * 18.0 + (1.0 / attack_interval) * 45.0 + crit_chance * 180.0))
	return {
		"attack": attack,
		"max_hp": max_hp,
		"defense": defense,
		"attack_interval": attack_interval,
		"gold_multiplier": gold_multiplier,
		"crit_chance": crit_chance,
		"power": power
	}


func get_upgrade_cost(id: String) -> int:
	return GameDataClass.get_upgrade_cost(id, int(upgrade_levels.get(id, 0)))


func can_purchase_upgrade(id: String) -> bool:
	return gold >= get_upgrade_cost(id)


func purchase_upgrade(id: String) -> bool:
	if not can_purchase_upgrade(id):
		return false

	var old_max_hp := int(get_player_stats()["max_hp"])
	gold -= get_upgrade_cost(id)
	upgrade_levels[id] = int(upgrade_levels.get(id, 0)) + 1
	if id == "hp":
		var new_max_hp := int(get_player_stats()["max_hp"])
		player_hp += float(new_max_hp - old_max_hp)
	return true


func spawn_enemy() -> void:
	enemy_data = GameDataClass.get_enemy_for_stage(current_stage, boss_clear_state)
	is_boss = current_stage >= GameDataClass.MAX_STAGE and not boss_clear_state
	enemy_max_hp = float(enemy_data["hp"])
	enemy_hp = enemy_max_hp


func roll_player_damage() -> Dictionary:
	var stats: Dictionary = get_player_stats()
	var damage := float(stats["attack"]) * rng.randf_range(0.92, 1.08)
	var critical := rng.randf() < float(stats["crit_chance"])
	if critical:
		damage *= 1.75
	return {"damage": int(round(damage)), "critical": critical}


func damage_enemy(amount: int) -> Dictionary:
	enemy_hp = max(0.0, enemy_hp - float(amount))
	if enemy_hp > 0.0:
		return {"defeated": false}

	var reward: Dictionary = _grant_enemy_reward()
	var cleared_boss: bool = is_boss
	if cleared_boss:
		boss_clear_state = true
	else:
		current_enemy_progress += 1
		if current_enemy_progress >= GameDataClass.KILLS_PER_STAGE:
			current_enemy_progress = 0
			current_stage = min(GameDataClass.MAX_STAGE, current_stage + 1)

	spawn_enemy()
	return {
		"defeated": true,
		"boss_clear": cleared_boss,
		"reward": reward
	}


func enemy_attack_player() -> Dictionary:
	if boss_clear_state and current_stage >= GameDataClass.MAX_STAGE:
		return {"damage": 0, "player_down": false}

	var stats: Dictionary = get_player_stats()
	var raw_damage := int(enemy_data["damage"])
	var final_damage: int = max(1, raw_damage - int(stats["defense"]))
	player_hp -= float(final_damage)
	var player_down := player_hp <= 0.0
	if player_down:
		player_hp = float(stats["max_hp"])
	return {"damage": final_damage, "player_down": player_down}


func apply_offline_reward(now_time: int) -> int:
	if last_play_time <= 0:
		last_play_time = now_time
		return 0

	var offline_seconds: int = clamp(now_time - last_play_time, 0, GameDataClass.OFFLINE_REWARD_CAP_SECONDS)
	if offline_seconds < 30:
		last_play_time = now_time
		return 0

	var stats: Dictionary = get_player_stats()
	var gold_per_second: float = max(0.8, (float(stats["attack"]) / float(stats["attack_interval"])) * 0.18) * float(stats["gold_multiplier"])
	var reward := int(round(gold_per_second * float(offline_seconds)))
	gold += reward
	last_play_time = now_time
	return reward


func to_save_dict() -> Dictionary:
	return {
		"save_version": GameDataClass.SAVE_VERSION,
		"gold": gold,
		"player_level": player_level,
		"exp": exp,
		"current_stage": current_stage,
		"current_enemy_progress": current_enemy_progress,
		"upgrade_levels": upgrade_levels.duplicate(true),
		"boss_clear_state": boss_clear_state,
		"last_play_time": last_play_time,
		"settings": settings.duplicate(true)
	}


func load_from_dict(data: Dictionary) -> void:
	reset(false)
	gold = int(data.get("gold", 0))
	player_level = max(1, int(data.get("player_level", 1)))
	exp = max(0, int(data.get("exp", 0)))
	current_stage = clamp(int(data.get("current_stage", 1)), 1, GameDataClass.MAX_STAGE)
	current_enemy_progress = clamp(int(data.get("current_enemy_progress", 0)), 0, GameDataClass.KILLS_PER_STAGE - 1)
	var loaded_upgrades: Dictionary = data.get("upgrade_levels", {})
	for id in GameDataClass.get_upgrade_ids():
		upgrade_levels[id] = max(0, int(loaded_upgrades.get(id, 0)))
	boss_clear_state = bool(data.get("boss_clear_state", false))
	last_play_time = int(data.get("last_play_time", 0))
	settings = data.get("settings", {"number_format": "short"})
	restore_player()
	spawn_enemy()


func _grant_enemy_reward() -> Dictionary:
	var stats: Dictionary = get_player_stats()
	var earned_gold := int(round(float(enemy_data["gold"]) * float(stats["gold_multiplier"])))
	var earned_exp := int(enemy_data["exp"])
	gold += earned_gold
	exp += earned_exp
	var leveled := false
	while exp >= exp_to_next_level():
		exp -= exp_to_next_level()
		player_level += 1
		leveled = true
	if leveled:
		restore_player()
	return {"gold": earned_gold, "exp": earned_exp, "leveled": leveled}
