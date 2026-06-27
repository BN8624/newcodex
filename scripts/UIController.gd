# 공통 UI 스타일과 숫자 표시를 제공하는 화면 보조 유틸리티
extends RefCounted
class_name UIController


static func panel_style(color: Color, border_color := Color(1, 1, 1, 0.12), radius := 8) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


static func button_style(color: Color, radius := 7) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.border_color = Color(1, 1, 1, 0.16)
	style.set_border_width_all(1)
	return style


static func format_number(value: int) -> String:
	var abs_value: int = abs(value)
	if abs_value >= 1000000000000:
		return str(round(float(value) / 10000000000.0) / 100.0) + "조"
	if abs_value >= 100000000:
		return str(round(float(value) / 1000000.0) / 100.0) + "억"
	if abs_value >= 10000:
		return str(round(float(value) / 100.0) / 100.0) + "만"
	return str(value)


static func set_bar(bar: ProgressBar, current: float, maximum: float) -> void:
	bar.max_value = 100.0
	bar.value = 0.0 if maximum <= 0.0 else clamp((current / maximum) * 100.0, 0.0, 100.0)
