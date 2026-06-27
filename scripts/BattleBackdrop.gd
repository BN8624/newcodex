# 전투 화면의 배경, 별빛, 지형을 코드로 그리는 장식 뷰
extends Control
class_name BattleBackdrop

var time := 0.0
var redraw_timer := 0.0
var stars := [
	Vector2(58, 62),
	Vector2(108, 104),
	Vector2(174, 54),
	Vector2(248, 112),
	Vector2(316, 48),
	Vector2(432, 82),
	Vector2(464, 138),
	Vector2(392, 190),
	Vector2(78, 190),
	Vector2(212, 174)
]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	redraw_timer += delta
	if redraw_timer >= 0.08:
		redraw_timer = 0.0
		queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.045, 0.105, 1.0), true)
	draw_rect(Rect2(0, h * 0.45, w, h * 0.55), Color(0.04, 0.085, 0.13, 0.82), true)

	var moon_center := Vector2(w * 0.78, h * 0.18)
	var glow := 28.0 + sin(time * 1.4) * 3.0
	draw_circle(moon_center, glow + 22.0, Color(0.45, 0.62, 1.0, 0.08))
	draw_circle(moon_center, glow, Color(0.72, 0.86, 1.0, 0.2))
	draw_circle(moon_center + Vector2(-4, -3), 22.0, Color(0.98, 0.94, 0.72, 0.9))
	draw_circle(moon_center + Vector2(8, -5), 18.0, Color(0.025, 0.045, 0.105, 0.8))

	for i in range(stars.size()):
		var p: Vector2 = stars[i]
		var a := 0.35 + sin(time * 2.0 + float(i) * 0.7) * 0.22
		_draw_star(p, 4.0 + float(i % 3), Color(0.78, 0.9, 1.0, a))

	var hill_far := PackedVector2Array([
		Vector2(0, h * 0.72),
		Vector2(w * 0.16, h * 0.58),
		Vector2(w * 0.34, h * 0.69),
		Vector2(w * 0.56, h * 0.53),
		Vector2(w * 0.82, h * 0.7),
		Vector2(w, h * 0.57),
		Vector2(w, h),
		Vector2(0, h)
	])
	draw_polygon(hill_far, PackedColorArray([Color(0.055, 0.1, 0.13, 1.0)]))

	var hill_near := PackedVector2Array([
		Vector2(0, h * 0.8),
		Vector2(w * 0.2, h * 0.68),
		Vector2(w * 0.46, h * 0.78),
		Vector2(w * 0.72, h * 0.66),
		Vector2(w, h * 0.76),
		Vector2(w, h),
		Vector2(0, h)
	])
	draw_polygon(hill_near, PackedColorArray([Color(0.035, 0.12, 0.11, 1.0)]))
	draw_rect(Rect2(0, h * 0.8, w, h * 0.2), Color(0.045, 0.15, 0.12, 0.95), true)
	draw_line(Vector2(0, h * 0.8), Vector2(w, h * 0.8), Color(0.85, 0.95, 1.0, 0.13), 2.0)


func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), color, 1.2)
	draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), color, 1.2)
