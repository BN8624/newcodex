# 게임 밸런스와 스테이지 데이터를 제공하는 정적 데이터 모음
extends RefCounted
class_name GameData

const SAVE_VERSION := 1
const REGION_NAME := "달샘 폐허"
const MAX_STAGE := 15
const KILLS_PER_STAGE := 3
const OFFLINE_REWARD_CAP_SECONDS := 7200

const UPGRADES := {
	"attack": {
		"name": "달빛검",
		"desc": "공격력",
		"base_cost": 12,
		"cost_growth": 1.18
	},
	"hp": {
		"name": "수호의 심장",
		"desc": "최대 체력",
		"base_cost": 16,
		"cost_growth": 1.18
	},
	"defense": {
		"name": "결계 갑옷",
		"desc": "방어력",
		"base_cost": 18,
		"cost_growth": 1.19
	},
	"speed": {
		"name": "신속 의식",
		"desc": "공격 속도",
		"base_cost": 24,
		"cost_growth": 1.2
	},
	"gold": {
		"name": "황금 부적",
		"desc": "골드 획득",
		"base_cost": 20,
		"cost_growth": 1.18
	},
	"crit": {
		"name": "별빛 징표",
		"desc": "치명 확률",
		"base_cost": 28,
		"cost_growth": 1.2
	}
}

const ENEMIES := [
	{
		"name": "초승달 혼령",
		"hp": 34,
		"damage": 5,
		"gold": 9,
		"exp": 7,
		"color": Color(0.45, 0.8, 1.0)
	},
	{
		"name": "이끼 파수꾼",
		"hp": 42,
		"damage": 7,
		"gold": 11,
		"exp": 8,
		"color": Color(0.42, 0.9, 0.45)
	},
	{
		"name": "호박빛 그림자",
		"hp": 52,
		"damage": 9,
		"gold": 13,
		"exp": 10,
		"color": Color(1.0, 0.65, 0.28)
	},
	{
		"name": "룬 껍질수",
		"hp": 64,
		"damage": 11,
		"gold": 16,
		"exp": 12,
		"color": Color(0.72, 0.6, 1.0)
	}
]

const BOSS := {
	"name": "달그늘 거상",
	"hp": 980,
	"damage": 24,
	"gold": 420,
	"exp": 140,
	"color": Color(1.0, 0.32, 0.42)
}

const CLEAR_TARGET := {
	"name": "새벽 관문",
	"hp": 260,
	"damage": 4,
	"gold": 35,
	"exp": 12,
	"color": Color(1.0, 0.92, 0.55)
}

static func get_upgrade_ids() -> Array:
	return ["attack", "hp", "defense", "speed", "gold", "crit"]


static func get_upgrade(id: String) -> Dictionary:
	return UPGRADES[id]


static func get_upgrade_cost(id: String, level: int) -> int:
	var data: Dictionary = get_upgrade(id)
	return int(round(float(data["base_cost"]) * pow(float(data["cost_growth"]), float(level))))


static func get_enemy_for_stage(stage: int, boss_clear_state: bool) -> Dictionary:
	if boss_clear_state:
		return CLEAR_TARGET.duplicate(true)
	if stage >= MAX_STAGE:
		return BOSS.duplicate(true)

	var enemy: Dictionary = ENEMIES[(stage - 1) % ENEMIES.size()].duplicate(true)
	var scale: float = pow(1.14, float(stage - 1))
	enemy["hp"] = int(round(float(enemy["hp"]) * scale))
	enemy["damage"] = int(round(float(enemy["damage"]) * pow(1.08, float(stage - 1))))
	enemy["gold"] = int(round(float(enemy["gold"]) * pow(1.12, float(stage - 1))))
	enemy["exp"] = int(round(float(enemy["exp"]) * pow(1.08, float(stage - 1))))
	return enemy
