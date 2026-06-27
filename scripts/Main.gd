# 540x960 세로형 idle RPG 화면과 게임 루프를 연결하는 메인 컨트롤러
extends Control

const GameDataClass := preload("res://data/game_data.gd")
const GameStateClass := preload("res://scripts/GameState.gd")
const CombatControllerClass := preload("res://scripts/CombatController.gd")
const SaveManagerClass := preload("res://scripts/SaveManager.gd")
const UIControllerClass := preload("res://scripts/UIController.gd")
const EffectsClass := preload("res://scripts/Effects.gd")
const VerifierClass := preload("res://scripts/Verifier.gd")
const BattleActorViewClass := preload("res://scripts/BattleActorView.gd")
const BattleBackdropClass := preload("res://scripts/BattleBackdrop.gd")
const SoundManagerClass := preload("res://scripts/SoundManager.gd")
const AssetTexturesClass := preload("res://scripts/AssetTextures.gd")

const KOREAN_FONT_PATH := "res://malgun.ttf"
const SKILL_COOLDOWN := 7.0

var state
var combat
var korean_font: Font
var sound

var title_label: Label
var subtitle_label: Label
var stage_label: Label
var gold_label: Label
var level_label: Label
var power_label: Label
var progress_label: Label
var goal_label: Label
var mode_label: Label
var enemy_name_label: Label
var enemy_tag_label: Label
var enemy_hp_label: Label
var player_hp_label: Label
var boss_label: Label
var reward_label: Label
var clear_label: Label
var stage_path_label: Label
var enemy_hp_bar: ProgressBar
var player_hp_bar: ProgressBar
var exp_bar: ProgressBar
var battle_panel: Panel
var hero_sprite
var enemy_sprite
var upgrade_buttons := {}
var reset_button: Button
var skill_button: Button
var autosave_timer: Timer
var ui_refresh_timer := 0.0
var reset_pending := false
var skill_cooldown := 0.0


func _ready() -> void:
	if OS.get_cmdline_user_args().has("--verify"):
		var ok := VerifierClass.run()
		get_tree().quit(0 if ok else 1)
		return

	custom_minimum_size = Vector2(540, 960)
	_apply_korean_font_theme()
	sound = SoundManagerClass.new()
	add_child(sound)
	_build_ui()
	_apply_korean_font_to(self)
	_load_or_start()
	_start_combat()
	_setup_autosave()
	_update_ui()


func _process(delta: float) -> void:
	if skill_cooldown > 0.0:
		var cooldown_delta: float = delta / max(Engine.time_scale, 0.1)
		skill_cooldown = max(0.0, skill_cooldown - cooldown_delta)
	ui_refresh_timer += delta
	if ui_refresh_timer >= 0.12:
		ui_refresh_timer = 0.0
		_update_ui()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and state != null:
		SaveManagerClass.save_game(state)


func _build_ui() -> void:
	var bg_texture := GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.06, 0.08, 0.16))
	gradient.set_color(1, Color(0.11, 0.22, 0.34))
	bg_texture.gradient = gradient
	bg_texture.fill_from = Vector2(0, 0)
	bg_texture.fill_to = Vector2(0, 1)

	var bg := TextureRect.new()
	bg.texture = bg_texture
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_build_top_panel()
	_build_battle_panel()
	_build_upgrade_panel()


func _build_top_panel() -> void:
	var top := Panel.new()
	top.position = Vector2(14, 14)
	top.size = Vector2(512, 132)
	top.add_theme_stylebox_override("panel", UIControllerClass.panel_style(Color(0.045, 0.06, 0.12, 0.96), Color(0.78, 0.9, 1.0, 0.22), 8))
	add_child(top)

	mode_label = _label("자동 전투", 12, Color(0.05, 0.07, 0.12))
	mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mode_label.position = Vector2(366, 10)
	mode_label.size = Vector2(126, 22)
	mode_label.add_theme_stylebox_override("normal", UIControllerClass.panel_style(Color(0.93, 0.84, 0.36, 0.96), Color(1, 1, 1, 0.15), 6))
	top.add_child(mode_label)

	title_label = _label("달샘 수호자", 26, Color(0.98, 0.94, 0.75))
	title_label.position = Vector2(14, 8)
	title_label.size = Vector2(340, 30)
	top.add_child(title_label)

	subtitle_label = _label("달샘 폐허 공개 확인 빌드", 12, Color(0.7, 0.8, 0.95))
	subtitle_label.position = Vector2(16, 34)
	subtitle_label.size = Vector2(360, 18)
	top.add_child(subtitle_label)

	stage_label = _label("", 18, Color(0.82, 0.9, 1.0))
	stage_label.position = Vector2(16, 56)
	stage_label.size = Vector2(240, 24)
	top.add_child(stage_label)

	gold_label = _label("", 18, Color(1.0, 0.86, 0.35))
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold_label.position = Vector2(258, 56)
	gold_label.size = Vector2(238, 24)
	top.add_child(gold_label)

	level_label = _label("", 16, Color(0.85, 1.0, 0.86))
	level_label.position = Vector2(16, 84)
	level_label.size = Vector2(166, 22)
	top.add_child(level_label)

	power_label = _label("", 16, Color(0.95, 0.78, 1.0))
	power_label.position = Vector2(188, 84)
	power_label.size = Vector2(160, 22)
	top.add_child(power_label)

	progress_label = _label("", 16, Color(0.86, 0.92, 1.0))
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	progress_label.position = Vector2(338, 84)
	progress_label.size = Vector2(158, 22)
	top.add_child(progress_label)

	exp_bar = _bar(Color(0.55, 0.9, 0.6))
	exp_bar.position = Vector2(16, 112)
	exp_bar.size = Vector2(480, 12)
	top.add_child(exp_bar)


func _build_battle_panel() -> void:
	battle_panel = Panel.new()
	battle_panel.position = Vector2(14, 158)
	battle_panel.size = Vector2(512, 442)
	battle_panel.add_theme_stylebox_override("panel", UIControllerClass.panel_style(Color(0.05, 0.08, 0.13, 0.94), Color(0.8, 0.88, 1.0, 0.18), 8))
	add_child(battle_panel)

	var backdrop = BattleBackdropClass.new()
	backdrop.position = Vector2(0, 0)
	backdrop.size = battle_panel.size
	battle_panel.add_child(backdrop)

	var moon := ColorRect.new()
	moon.color = Color(0.7, 0.86, 1.0, 0.12)
	moon.position = Vector2(354, 30)
	moon.size = Vector2(86, 86)
	battle_panel.add_child(moon)

	var ground := ColorRect.new()
	ground.color = Color(0.06, 0.14, 0.13, 0.95)
	ground.position = Vector2(10, 336)
	ground.size = Vector2(492, 84)
	battle_panel.add_child(ground)

	goal_label = _label("", 15, Color(0.83, 0.9, 1.0))
	goal_label.position = Vector2(20, 16)
	goal_label.size = Vector2(180, 24)
	goal_label.add_theme_stylebox_override("normal", UIControllerClass.panel_style(Color(0.1, 0.14, 0.22, 0.82), Color(1, 1, 1, 0.12), 6))
	battle_panel.add_child(goal_label)

	enemy_name_label = _label("", 21, Color(1.0, 0.9, 0.8))
	enemy_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_name_label.position = Vector2(68, 38)
	enemy_name_label.size = Vector2(376, 28)
	battle_panel.add_child(enemy_name_label)

	enemy_tag_label = _label("", 13, Color(0.7, 0.82, 0.96))
	enemy_tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_tag_label.position = Vector2(92, 64)
	enemy_tag_label.size = Vector2(328, 20)
	battle_panel.add_child(enemy_tag_label)

	enemy_hp_bar = _bar(Color(0.95, 0.25, 0.35))
	enemy_hp_bar.position = Vector2(82, 86)
	enemy_hp_bar.size = Vector2(348, 20)
	battle_panel.add_child(enemy_hp_bar)

	enemy_hp_label = _label("", 13, Color(1, 1, 1, 0.88))
	enemy_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_hp_label.position = Vector2(82, 84)
	enemy_hp_label.size = Vector2(348, 20)
	battle_panel.add_child(enemy_hp_label)

	boss_label = _label("보스 출현", 24, Color(1.0, 0.38, 0.42))
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.position = Vector2(74, 114)
	boss_label.size = Vector2(364, 34)
	boss_label.visible = false
	battle_panel.add_child(boss_label)

	enemy_sprite = BattleActorViewClass.new()
	enemy_sprite.setup("enemy", Color(0.45, 0.8, 1.0), "res://assets/kenney/tiny-dungeon/Tiles/tile_0121.png")
	enemy_sprite.position = Vector2(318, 146)
	enemy_sprite.size = Vector2(126, 142)
	battle_panel.add_child(enemy_sprite)

	hero_sprite = BattleActorViewClass.new()
	hero_sprite.setup("hero", Color(0.72, 0.95, 1.0), "res://assets/kenney/tiny-dungeon/Tiles/tile_0097.png")
	hero_sprite.position = Vector2(68, 238)
	hero_sprite.size = Vector2(128, 148)
	battle_panel.add_child(hero_sprite)

	player_hp_bar = _bar(Color(0.3, 0.95, 0.58))
	player_hp_bar.position = Vector2(42, 405)
	player_hp_bar.size = Vector2(428, 20)
	battle_panel.add_child(player_hp_bar)

	player_hp_label = _label("", 13, Color(1, 1, 1, 0.9))
	player_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_hp_label.position = Vector2(42, 403)
	player_hp_label.size = Vector2(428, 22)
	battle_panel.add_child(player_hp_label)

	reward_label = _label("", 22, Color(1.0, 0.88, 0.38))
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.position = Vector2(56, 300)
	reward_label.size = Vector2(400, 34)
	reward_label.visible = false
	battle_panel.add_child(reward_label)

	stage_path_label = _label("", 14, Color(0.84, 0.9, 1.0))
	stage_path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_path_label.position = Vector2(30, 370)
	stage_path_label.size = Vector2(452, 24)
	battle_panel.add_child(stage_path_label)

	clear_label = _label("", 28, Color(1.0, 0.96, 0.74))
	clear_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clear_label.position = Vector2(32, 126)
	clear_label.size = Vector2(448, 86)
	clear_label.visible = false
	clear_label.add_theme_stylebox_override("normal", UIControllerClass.panel_style(Color(0.18, 0.12, 0.24, 0.94), Color(1.0, 0.82, 0.3, 0.38), 8))
	battle_panel.add_child(clear_label)


func _build_upgrade_panel() -> void:
	var bottom := Panel.new()
	bottom.position = Vector2(14, 616)
	bottom.size = Vector2(512, 330)
	bottom.add_theme_stylebox_override("panel", UIControllerClass.panel_style(Color(0.07, 0.09, 0.16, 0.96), Color(0.8, 0.88, 1.0, 0.14), 8))
	add_child(bottom)

	var title := _label("성장 상점", 20, Color(0.92, 0.96, 1.0))
	title.position = Vector2(14, 8)
	title.size = Vector2(170, 28)
	bottom.add_child(title)

	var hint := _label("불이 켜진 성장은 바로 누르세요.", 13, Color(0.68, 0.76, 0.88))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.position = Vector2(210, 12)
	hint.size = Vector2(288, 20)
	bottom.add_child(hint)

	var ids := GameDataClass.get_upgrade_ids()
	for i in range(ids.size()):
		var id := String(ids[i])
		var button := Button.new()
		button.position = Vector2(14, 40 + i * 40)
		button.size = Vector2(484, 35)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 13)
		button.add_theme_stylebox_override("normal", UIControllerClass.button_style(Color(0.14, 0.18, 0.28)))
		button.add_theme_stylebox_override("hover", UIControllerClass.button_style(Color(0.18, 0.24, 0.36)))
		button.add_theme_stylebox_override("pressed", UIControllerClass.button_style(Color(0.22, 0.3, 0.44)))
		button.add_theme_stylebox_override("disabled", UIControllerClass.button_style(Color(0.08, 0.09, 0.12)))
		var upgrade := GameDataClass.get_upgrade(id)
		var icon := AssetTexturesClass.load_png(String(upgrade["icon"]))
		if icon != null:
			button.icon = icon
			button.expand_icon = true
			button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.pressed.connect(_on_upgrade_pressed.bind(id))
		bottom.add_child(button)
		upgrade_buttons[id] = button

	var save_button := Button.new()
	save_button.text = "저장"
	save_button.position = Vector2(254, 288)
	save_button.size = Vector2(82, 30)
	save_button.focus_mode = Control.FOCUS_NONE
	save_button.pressed.connect(_on_save_pressed)
	bottom.add_child(save_button)

	reset_button = Button.new()
	reset_button.text = "새 게임"
	reset_button.position = Vector2(344, 288)
	reset_button.size = Vector2(154, 30)
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.pressed.connect(_on_reset_pressed)
	bottom.add_child(reset_button)

	skill_button = Button.new()
	skill_button.text = "월광 폭발"
	skill_button.position = Vector2(14, 288)
	skill_button.size = Vector2(232, 30)
	skill_button.focus_mode = Control.FOCUS_NONE
	skill_button.add_theme_font_size_override("font_size", 15)
	skill_button.add_theme_stylebox_override("normal", UIControllerClass.button_style(Color(0.22, 0.17, 0.38)))
	skill_button.add_theme_stylebox_override("pressed", UIControllerClass.button_style(Color(0.32, 0.22, 0.52)))
	skill_button.add_theme_stylebox_override("disabled", UIControllerClass.button_style(Color(0.09, 0.08, 0.12)))
	skill_button.pressed.connect(_on_skill_pressed)
	bottom.add_child(skill_button)


func _load_or_start() -> void:
	state = GameStateClass.new()
	var data := SaveManagerClass.load_game()
	if not data.is_empty():
		state.load_from_dict(data)
	var offline_reward: int = state.apply_offline_reward(Time.get_unix_time_from_system())
	if offline_reward > 0:
		_show_reward("자리 비운 동안 골드 +" + UIControllerClass.format_number(offline_reward))
		SaveManagerClass.save_game(state)


func _start_combat() -> void:
	combat = CombatControllerClass.new()
	add_child(combat)
	combat.enemy_hit.connect(_on_enemy_hit)
	combat.player_hit.connect(_on_player_hit)
	combat.enemy_defeated.connect(_on_enemy_defeated)
	combat.boss_cleared.connect(_on_boss_cleared)
	combat.player_down.connect(_on_player_down)
	combat.enemy_spawned.connect(_on_enemy_spawned)
	combat.start(state)


func _setup_autosave() -> void:
	autosave_timer = Timer.new()
	autosave_timer.wait_time = 8.0
	autosave_timer.autostart = true
	autosave_timer.timeout.connect(func(): SaveManagerClass.save_game(state))
	add_child(autosave_timer)


func _update_ui() -> void:
	if state == null:
		return

	var stats: Dictionary = state.get_player_stats()
	stage_label.text = GameDataClass.REGION_NAME + "  " + _stage_text()
	gold_label.text = "골드 " + UIControllerClass.format_number(state.gold)
	level_label.text = str(state.player_level) + "레벨  경험치 " + str(state.exp) + "/" + str(state.exp_to_next_level())
	power_label.text = "전투력 " + UIControllerClass.format_number(int(stats["power"]))
	progress_label.text = "진행 " + str(state.current_enemy_progress) + "/" + str(GameDataClass.KILLS_PER_STAGE)
	goal_label.text = _goal_text()
	enemy_name_label.text = state.enemy_data["name"]
	enemy_tag_label.text = _enemy_tag_text()
	enemy_hp_label.text = UIControllerClass.format_number(int(ceil(state.enemy_hp))) + " / " + UIControllerClass.format_number(int(state.enemy_max_hp))
	player_hp_label.text = "체력 " + UIControllerClass.format_number(int(ceil(state.player_hp))) + " / " + UIControllerClass.format_number(int(stats["max_hp"]))
	UIControllerClass.set_bar(enemy_hp_bar, state.enemy_hp, state.enemy_max_hp)
	UIControllerClass.set_bar(player_hp_bar, state.player_hp, float(stats["max_hp"]))
	UIControllerClass.set_bar(exp_bar, float(state.exp), float(state.exp_to_next_level()))
	boss_label.visible = state.is_boss
	stage_path_label.text = _stage_path_text()

	for id in upgrade_buttons.keys():
		_refresh_upgrade_button(String(id))

	if skill_button != null:
		if skill_cooldown > 0.0:
			skill_button.disabled = true
			skill_button.text = "월광 폭발 " + str(int(ceil(skill_cooldown))) + "초"
		else:
			skill_button.disabled = state == null or state.boss_clear_state
			skill_button.text = "월광 폭발"


func _refresh_upgrade_button(id: String) -> void:
	var button: Button = upgrade_buttons[id]
	var upgrade := GameDataClass.get_upgrade(id)
	var level := int(state.upgrade_levels.get(id, 0))
	var cost: int = state.get_upgrade_cost(id)
	var buy_text := "구매 가능" if state.can_purchase_upgrade(id) else "골드 부족"
	button.text = "[" + buy_text + "] " + String(upgrade["name"]) + "  " + str(level) + "단계   " + String(upgrade["desc"]) + "   비용 " + UIControllerClass.format_number(cost)
	button.disabled = not state.can_purchase_upgrade(id)


func _on_upgrade_pressed(id: String) -> void:
	if state.purchase_upgrade(id):
		var button: Button = upgrade_buttons[id]
		EffectsClass.button_pop(button)
		EffectsClass.floating_text(self, "성장 완료", Vector2(270, 642), Color(0.55, 1.0, 0.58), 24)
		EffectsClass.spark_burst(self, Vector2(270, 662), Color(0.75, 1.0, 0.58, 0.95), 14)
		_play_sound("level")
		SaveManagerClass.save_game(state)
		_update_ui()


func _on_save_pressed() -> void:
	if SaveManagerClass.save_game(state):
		_play_sound("button")
		_show_reward("저장 완료")


func _on_reset_pressed() -> void:
	if not reset_pending:
		reset_pending = true
		reset_button.text = "초기화 확인"
		_play_sound("button")
		_show_reward("한 번 더 누르면 초기화")
		var timer := get_tree().create_timer(3.0)
		timer.timeout.connect(func():
			reset_pending = false
			if reset_button != null:
				reset_button.text = "새 게임"
		)
		return

	reset_pending = false
	SaveManagerClass.delete_save()
	state.reset()
	combat.start(state)
	_play_sound("button")
	_show_reward("새 여정 시작")
	_update_ui()


func _on_skill_pressed() -> void:
	if state == null or skill_cooldown > 0.0 or state.boss_clear_state:
		return
	EffectsClass.button_pop(skill_button)
	var stats: Dictionary = state.get_player_stats()
	var amount := int(round(float(stats["attack"]) * 3.6 + float(state.player_level) * 3.0))
	var result: Dictionary = state.damage_enemy(amount)
	EffectsClass.floating_text(battle_panel, "월광 -" + UIControllerClass.format_number(amount), enemy_sprite.position + Vector2(enemy_sprite.size.x * 0.5, 4), Color(0.72, 0.92, 1.0), 24)
	EffectsClass.pulse_ring(battle_panel, enemy_sprite.position + enemy_sprite.size * 0.5, Color(0.72, 0.92, 1.0, 0.9), 42.0)
	EffectsClass.spark_burst(battle_panel, enemy_sprite.position + enemy_sprite.size * 0.5, Color(0.62, 0.86, 1.0, 0.95), 18)
	EffectsClass.flash(enemy_sprite, Color(0.78, 0.92, 1.0), 0.12)
	EffectsClass.shake(battle_panel, 7.0)
	_play_sound("skill")
	skill_cooldown = SKILL_COOLDOWN
	if bool(result.get("defeated", false)):
		_on_enemy_defeated(result)
		if bool(result.get("boss_clear", false)):
			_on_boss_cleared(result)
		_on_enemy_spawned()
	_update_ui()


func _on_enemy_hit(amount: int, critical: bool) -> void:
	var text := ("치명타 " if critical else "") + "-" + UIControllerClass.format_number(amount)
	var color := Color(1.0, 0.95, 0.45) if critical else Color(1.0, 0.45, 0.36)
	EffectsClass.floating_text(battle_panel, text, enemy_sprite.position + Vector2(enemy_sprite.size.x * 0.5, 18), color, 24 if critical else 20)
	EffectsClass.spark_burst(battle_panel, enemy_sprite.position + enemy_sprite.size * 0.5, color, 10 if critical else 6)
	EffectsClass.flash(enemy_sprite, Color(1.0, 0.88, 0.88), 0.1)
	EffectsClass.bump(hero_sprite, Vector2(12, -3), 0.12)
	EffectsClass.hit_pause(self, 0.035 if critical else 0.02)
	_play_sound("crit" if critical else "hit")
	if state.is_boss:
		EffectsClass.shake(battle_panel, 5.0)
	_update_ui()


func _on_player_hit(amount: int) -> void:
	EffectsClass.floating_text(battle_panel, "-" + UIControllerClass.format_number(amount), hero_sprite.position + Vector2(50, 4), Color(0.72, 0.9, 1.0), 18)
	EffectsClass.flash(hero_sprite, Color(0.8, 0.9, 1.0), 0.1)
	EffectsClass.spark_burst(battle_panel, hero_sprite.position + Vector2(54, 30), Color(0.45, 0.75, 1.0, 0.78), 5)
	_update_ui()


func _on_enemy_defeated(result: Dictionary) -> void:
	var reward: Dictionary = result["reward"]
	var message := "골드 +" + UIControllerClass.format_number(int(reward["gold"])) + "  경험치 +" + str(int(reward["exp"]))
	if bool(reward["leveled"]):
		message += "  레벨 상승"
		_play_sound("level")
	else:
		_play_sound("reward")
	EffectsClass.pulse_ring(battle_panel, enemy_sprite.position + enemy_sprite.size * 0.5, Color(1.0, 0.86, 0.36, 0.75), 34.0)
	_show_reward(message)
	SaveManagerClass.save_game(state)
	_update_ui()


func _on_boss_cleared(result: Dictionary) -> void:
	_play_sound("clear")
	EffectsClass.spark_burst(battle_panel, Vector2(256, 198), Color(1.0, 0.88, 0.36, 0.95), 28)
	_show_clear_banner("지역 클리어\n달샘 폐허 정화 완료\n다음 지역 준비 중")
	SaveManagerClass.save_game(state)
	_update_ui()


func _on_player_down() -> void:
	_show_reward("수호자 재정비")
	_update_ui()


func _on_enemy_spawned() -> void:
	if state == null:
		return
	var color: Color = state.enemy_data["color"]
	var sprite_path := String(state.enemy_data.get("sprite", ""))
	if state.is_boss:
		enemy_sprite.setup("boss", color, sprite_path)
		enemy_sprite.position = Vector2(286, 126)
		enemy_sprite.size = Vector2(166, 184)
		_play_sound("boss")
		_show_reward("보스전 시작")
	elif state.boss_clear_state:
		enemy_sprite.setup("gate", color, sprite_path)
		enemy_sprite.position = Vector2(314, 148)
		enemy_sprite.size = Vector2(136, 150)
	else:
		enemy_sprite.setup("enemy", color, sprite_path)
		enemy_sprite.position = Vector2(318, 146)
		enemy_sprite.size = Vector2(126, 142)
	_update_ui()


func _show_reward(text: String) -> void:
	reward_label.text = text
	reward_label.visible = true
	reward_label.modulate.a = 1.0
	var tween := reward_label.create_tween()
	tween.tween_property(reward_label, "modulate:a", 1.0, 0.8)
	tween.tween_property(reward_label, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func(): reward_label.visible = false)


func _show_clear_banner(text: String) -> void:
	clear_label.text = text
	clear_label.visible = true
	clear_label.modulate.a = 1.0
	var tween := clear_label.create_tween()
	tween.tween_property(clear_label, "scale", Vector2(1.03, 1.03), 0.18)
	tween.tween_property(clear_label, "scale", Vector2.ONE, 0.18)


func _stage_text() -> String:
	if state.boss_clear_state:
		return "클리어"
	if state.is_boss:
		return str(GameDataClass.MAX_STAGE) + "층 보스"
	return str(state.current_stage) + "/" + str(GameDataClass.MAX_STAGE) + "층"


func _goal_text() -> String:
	if state.boss_clear_state:
		return "클리어 - 새벽 관문 확보"
	if state.is_boss:
		return "지역 보스를 처치하세요"
	return str(GameDataClass.KILLS_PER_STAGE - state.current_enemy_progress) + "마리 더 처치하면 전진"


func _enemy_tag_text() -> String:
	if state.boss_clear_state:
		return "클리어 이후 보상 대상"
	if state.is_boss:
		return "지역 보스 - 큰 보상"
	return str(state.current_stage) + "층 적 - 자동 전투 중"


func _stage_path_text() -> String:
	var path_text := ""
	for i in range(1, GameDataClass.MAX_STAGE + 1):
		if state.boss_clear_state:
			path_text += "X" if i == GameDataClass.MAX_STAGE else "="
		elif i < state.current_stage:
			path_text += "="
		elif i == state.current_stage:
			path_text += "B" if state.is_boss else "O"
		else:
			path_text += "-"
	return "진행 경로  " + path_text


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.68))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


func _bar(fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", UIControllerClass.panel_style(Color(0.02, 0.025, 0.04, 0.84), Color(1, 1, 1, 0.12), 5))
	bar.add_theme_stylebox_override("fill", UIControllerClass.panel_style(fill_color, Color(1, 1, 1, 0), 5))
	return bar


func _sprite_panel(color: Color, radius: int) -> Panel:
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", UIControllerClass.panel_style(color, Color(1, 1, 1, 0.22), radius))
	return panel


func _play_sound(sound_id: String) -> void:
	if sound != null:
		sound.play(sound_id)


func _apply_korean_font_theme() -> void:
	if not ResourceLoader.exists(KOREAN_FONT_PATH):
		return
	korean_font = load(KOREAN_FONT_PATH)
	var root_theme := Theme.new()
	root_theme.default_font = korean_font
	theme = root_theme


func _apply_korean_font_to(node: Node) -> void:
	if korean_font == null:
		return
	if node is Label or node is Button:
		node.add_theme_font_override("font", korean_font)
	for child in node.get_children():
		_apply_korean_font_to(child)
