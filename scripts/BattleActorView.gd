# 전투 캐릭터 실루엣을 코드로 그리는 모바일용 임시 아트 뷰
extends Control
class_name BattleActorView

const AssetTexturesClass := preload("res://scripts/AssetTextures.gd")

var actor_mode := "enemy"
var accent_color := Color(0.45, 0.8, 1.0)
var sprite_texture: Texture2D
var pulse := 0.0


func _ready() -> void:
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func setup(new_mode: String, new_color: Color, sprite_path := "") -> void:
	actor_mode = new_mode
	accent_color = new_color
	sprite_texture = null
	sprite_texture = AssetTexturesClass.load_png(sprite_path)
	queue_redraw()


func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var bob := sin(pulse * 3.0) * 3.0
	var shadow_color := Color(0.0, 0.0, 0.0, 0.32)
	draw_ellipse(Vector2(w * 0.5, h * 0.89), w * 0.38, h * 0.07, shadow_color)

	if actor_mode == "hero":
		_draw_hero(w, h, bob)
	elif actor_mode == "boss":
		_draw_boss(w, h, bob)
	elif actor_mode == "gate":
		_draw_gate(w, h, bob)
	else:
		_draw_enemy(w, h, bob)


func _draw_hero(w: float, h: float, bob: float) -> void:
	if _draw_sprite_art(w, h, bob, Color(0.72, 0.95, 1.0, 0.2), 6.5):
		return
	var outline := Color(0.04, 0.07, 0.12, 1.0)
	var cape := Color(0.12, 0.28, 0.46, 1.0)
	var armor := accent_color
	var gold := Color(1.0, 0.86, 0.32, 1.0)
	var y := bob

	draw_polygon(PackedVector2Array([
		Vector2(w * 0.18, h * 0.72 + y),
		Vector2(w * 0.5, h * 0.24 + y),
		Vector2(w * 0.82, h * 0.72 + y)
	]), PackedColorArray([cape, cape, cape]))
	draw_circle(Vector2(w * 0.5, h * 0.2 + y), w * 0.16, outline)
	draw_circle(Vector2(w * 0.5, h * 0.18 + y), w * 0.13, Color(0.94, 0.97, 1.0))
	draw_rect(Rect2(w * 0.34, h * 0.32 + y, w * 0.32, h * 0.38), outline, true)
	draw_rect(Rect2(w * 0.38, h * 0.35 + y, w * 0.24, h * 0.32), armor, true)
	draw_line(Vector2(w * 0.68, h * 0.34 + y), Vector2(w * 0.98, h * 0.06 + y), gold, 7.0)
	draw_line(Vector2(w * 0.7, h * 0.36 + y), Vector2(w * 1.0, h * 0.08 + y), Color(1, 1, 1, 0.55), 2.0)
	draw_rect(Rect2(w * 0.38, h * 0.68 + y, w * 0.08, h * 0.18), outline, true)
	draw_rect(Rect2(w * 0.54, h * 0.68 + y, w * 0.08, h * 0.18), outline, true)
	draw_circle(Vector2(w * 0.45, h * 0.18 + y), w * 0.025, outline)
	draw_circle(Vector2(w * 0.55, h * 0.18 + y), w * 0.025, outline)


func _draw_enemy(w: float, h: float, bob: float) -> void:
	if _draw_sprite_art(w, h, bob, Color(accent_color.r, accent_color.g, accent_color.b, 0.22), 6.0):
		return
	var outline := Color(0.03, 0.04, 0.08, 1.0)
	var body := accent_color
	var glow := Color(accent_color.r, accent_color.g, accent_color.b, 0.24)
	var y := bob

	draw_circle(Vector2(w * 0.5, h * 0.52 + y), w * 0.42, glow)
	draw_polygon(PackedVector2Array([
		Vector2(w * 0.18, h * 0.58 + y),
		Vector2(w * 0.28, h * 0.28 + y),
		Vector2(w * 0.5, h * 0.18 + y),
		Vector2(w * 0.75, h * 0.32 + y),
		Vector2(w * 0.86, h * 0.58 + y),
		Vector2(w * 0.72, h * 0.8 + y),
		Vector2(w * 0.32, h * 0.8 + y)
	]), PackedColorArray([outline, outline, outline, outline, outline, outline, outline]))
	draw_polygon(PackedVector2Array([
		Vector2(w * 0.24, h * 0.58 + y),
		Vector2(w * 0.33, h * 0.34 + y),
		Vector2(w * 0.5, h * 0.26 + y),
		Vector2(w * 0.68, h * 0.36 + y),
		Vector2(w * 0.78, h * 0.58 + y),
		Vector2(w * 0.66, h * 0.72 + y),
		Vector2(w * 0.36, h * 0.72 + y)
	]), PackedColorArray([body, body, body, body, body, body, body]))
	draw_circle(Vector2(w * 0.4, h * 0.5 + y), w * 0.045, Color(1, 1, 1))
	draw_circle(Vector2(w * 0.6, h * 0.5 + y), w * 0.045, Color(1, 1, 1))
	draw_circle(Vector2(w * 0.4, h * 0.51 + y), w * 0.024, outline)
	draw_circle(Vector2(w * 0.6, h * 0.51 + y), w * 0.024, outline)
	draw_line(Vector2(w * 0.4, h * 0.64 + y), Vector2(w * 0.62, h * 0.63 + y), outline, 4.0)


func _draw_boss(w: float, h: float, bob: float) -> void:
	if _draw_sprite_art(w, h, bob, Color(accent_color.r, accent_color.g, accent_color.b, 0.28), 7.6):
		return
	var outline := Color(0.04, 0.02, 0.05, 1.0)
	var body := accent_color
	var core := Color(1.0, 0.78, 0.32, 1.0)
	var y := bob

	draw_circle(Vector2(w * 0.5, h * 0.5 + y), w * 0.48, Color(body.r, body.g, body.b, 0.22))
	draw_rect(Rect2(w * 0.18, h * 0.22 + y, w * 0.64, h * 0.54), outline, true)
	draw_rect(Rect2(w * 0.24, h * 0.27 + y, w * 0.52, h * 0.44), body, true)
	draw_polygon(PackedVector2Array([
		Vector2(w * 0.2, h * 0.22 + y),
		Vector2(w * 0.08, h * 0.02 + y),
		Vector2(w * 0.38, h * 0.2 + y)
	]), PackedColorArray([outline, outline, outline]))
	draw_polygon(PackedVector2Array([
		Vector2(w * 0.8, h * 0.22 + y),
		Vector2(w * 0.92, h * 0.02 + y),
		Vector2(w * 0.62, h * 0.2 + y)
	]), PackedColorArray([outline, outline, outline]))
	draw_circle(Vector2(w * 0.4, h * 0.42 + y), w * 0.05, core)
	draw_circle(Vector2(w * 0.6, h * 0.42 + y), w * 0.05, core)
	draw_circle(Vector2(w * 0.5, h * 0.58 + y), w * 0.09, core)
	draw_line(Vector2(w * 0.34, h * 0.82 + y), Vector2(w * 0.34, h * 0.96 + y), outline, 10.0)
	draw_line(Vector2(w * 0.66, h * 0.82 + y), Vector2(w * 0.66, h * 0.96 + y), outline, 10.0)


func _draw_gate(w: float, h: float, bob: float) -> void:
	if _draw_sprite_art(w, h, bob, Color(1.0, 0.86, 0.3, 0.24), 6.8):
		return
	var y := bob
	var stone := Color(0.78, 0.74, 0.62, 1.0)
	var light := Color(1.0, 0.86, 0.3, 0.85)
	var dark := Color(0.08, 0.08, 0.12, 1.0)
	draw_rect(Rect2(w * 0.18, h * 0.2 + y, w * 0.64, h * 0.68), dark, true)
	draw_rect(Rect2(w * 0.24, h * 0.24 + y, w * 0.52, h * 0.6), stone, true)
	draw_circle(Vector2(w * 0.5, h * 0.34 + y), w * 0.26, stone)
	draw_rect(Rect2(w * 0.34, h * 0.4 + y, w * 0.32, h * 0.44), Color(0.08, 0.1, 0.16), true)
	draw_circle(Vector2(w * 0.5, h * 0.53 + y), w * 0.13, light)


func _draw_sprite_art(w: float, h: float, bob: float, glow_color: Color, scale_factor: float) -> bool:
	if sprite_texture == null:
		return false
	var center := Vector2(w * 0.5, h * 0.46 + bob)
	var sprite_size := Vector2(sprite_texture.get_width(), sprite_texture.get_height()) * scale_factor
	draw_circle(center, max(sprite_size.x, sprite_size.y) * 0.52, glow_color)
	draw_texture_rect(sprite_texture, Rect2(center - sprite_size * 0.5, sprite_size), false)
	draw_line(center + Vector2(-sprite_size.x * 0.34, sprite_size.y * 0.46), center + Vector2(sprite_size.x * 0.34, sprite_size.y * 0.46), Color(1, 1, 1, 0.16), 2.0)
	return true
