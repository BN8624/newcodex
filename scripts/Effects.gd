# 전투 숫자, 흔들림, 플래시 같은 짧은 시각 효과를 만든다
extends RefCounted
class_name Effects

const KOREAN_FONT_PATH := "res://malgun.ttf"

static var korean_font_checked := false
static var korean_font: Font


static func floating_text(parent: Control, text: String, start_pos: Vector2, color: Color, font_size := 22) -> void:
	var label := Label.new()
	label.text = text
	label.position = start_pos
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font := _get_korean_font()
	if font != null:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", start_pos.y - 58.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.08)
	tween.chain().tween_callback(label.queue_free)


static func _get_korean_font() -> Font:
	if not korean_font_checked:
		korean_font_checked = true
		if ResourceLoader.exists(KOREAN_FONT_PATH):
			korean_font = load(KOREAN_FONT_PATH)
	return korean_font


static func flash(node: CanvasItem, color := Color(1, 1, 1), duration := 0.12) -> void:
	var original := node.modulate
	node.modulate = color
	var tween := node.create_tween()
	tween.tween_property(node, "modulate", original, duration)


static func bump(control: Control, offset := Vector2(10, 0), duration := 0.12) -> void:
	var original := control.position
	var tween := control.create_tween()
	tween.tween_property(control, "position", original + offset, duration * 0.5)
	tween.tween_property(control, "position", original, duration * 0.5)


static func shake(control: Control, amount := 8.0) -> void:
	var original := control.position
	var tween := control.create_tween()
	tween.tween_property(control, "position", original + Vector2(amount, 0), 0.04)
	tween.tween_property(control, "position", original - Vector2(amount, 0), 0.04)
	tween.tween_property(control, "position", original, 0.04)
