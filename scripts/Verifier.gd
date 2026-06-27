# 핵심 게임 상태 동작을 빠르게 검증하는 헤드리스 테스트 러너
extends RefCounted
class_name Verifier

const GameStateClass := preload("res://scripts/GameState.gd")
const GameDataClass := preload("res://data/game_data.gd")


static func run() -> bool:
	var passed := true
	passed = _check_initial_state() and passed
	passed = _check_upgrade_changes_stats() and passed
	passed = _check_enemy_defeat_gives_reward() and passed
	passed = _check_stage_progression() and passed
	passed = _check_boss_clear() and passed
	passed = _check_crit_upgrade_changes_chance() and passed
	passed = _check_save_roundtrip() and passed
	print("VERIFY_RESULT: " + ("passed" if passed else "failed"))
	return passed


static func _expect(condition: bool, label: String) -> bool:
	if condition:
		print("PASS: " + label)
		return true
	push_error("FAIL: " + label)
	return false


static func _check_initial_state() -> bool:
	var state := GameStateClass.new()
	return _expect(state.current_stage == 1 and state.enemy_hp > 0.0 and state.gold == 0, "initial state valid")


static func _check_upgrade_changes_stats() -> bool:
	var state := GameStateClass.new()
	state.gold = 999
	var before := float(state.get_player_stats()["attack"])
	var bought := state.purchase_upgrade("attack")
	var after := float(state.get_player_stats()["attack"])
	return _expect(bought and after > before, "upgrade purchase changes stat")


static func _check_enemy_defeat_gives_reward() -> bool:
	var state := GameStateClass.new()
	var before_gold := state.gold
	state.enemy_hp = 1.0
	var result := state.damage_enemy(999)
	return _expect(bool(result["defeated"]) and state.gold > before_gold, "enemy defeat gives gold")


static func _check_stage_progression() -> bool:
	var state := GameStateClass.new()
	state.current_stage = 1
	state.current_enemy_progress = GameDataClass.KILLS_PER_STAGE - 1
	state.spawn_enemy()
	state.enemy_hp = 1.0
	state.damage_enemy(999)
	return _expect(state.current_stage == 2 and state.current_enemy_progress == 0, "stage progression works")


static func _check_boss_clear() -> bool:
	var state := GameStateClass.new()
	state.current_stage = GameDataClass.MAX_STAGE
	state.current_enemy_progress = 0
	state.spawn_enemy()
	state.enemy_hp = 1.0
	var result := state.damage_enemy(99999)
	return _expect(bool(result["boss_clear"]) and state.boss_clear_state, "boss clear sets clear state")


static func _check_crit_upgrade_changes_chance() -> bool:
	var state := GameStateClass.new()
	state.gold = 999
	var before := float(state.get_player_stats()["crit_chance"])
	var bought := state.purchase_upgrade("crit")
	var after := float(state.get_player_stats()["crit_chance"])
	return _expect(bought and after > before, "crit upgrade changes chance")


static func _check_save_roundtrip() -> bool:
	var state := GameStateClass.new()
	state.gold = 123
	state.player_level = 4
	state.upgrade_levels["attack"] = 2
	var copy := GameStateClass.new()
	copy.load_from_dict(state.to_save_dict())
	return _expect(copy.gold == 123 and copy.player_level == 4 and int(copy.upgrade_levels["attack"]) == 2, "save data roundtrip works")
