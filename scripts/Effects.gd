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


static func spark_burst(parent: Control, center: Vector2, color: Color, count := 16) -> void:
	for i in range(count):
		var particle := ColorRect.new()
		particle.color = color
		particle.position = center
		particle.size = Vector2(5, 5)
		particle.pivot_offset = particle.size * 0.5
		parent.add_child(particle)
		var angle := TAU * float(i) / float(count)
		var distance := 26.0 + float(i % 5) * 7.0
		var target := center + Vector2(cos(angle), sin(angle)) * distance
		var tween := parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "scale", Vector2(0.1, 0.1), 0.34)
		tween.tween_property(particle, "modulate:a", 0.0, 0.34)
		tween.chain().tween_callback(particle.queue_free)


static func pulse_ring(parent: Control, center: Vector2, color: Color, radius := 40.0) -> void:
	var ring := Panel.new()
	ring.position = center - Vector2(radius, radius)
	ring.size = Vector2(radius * 2.0, radius * 2.0)
	ring.pivot_offset = ring.size * 0.5
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.03)
	style.border_color = color
	style.set_border_width_all(3)
	style.set_corner_radius_all(int(radius))
	ring.add_theme_stylebox_override("panel", style)
	parent.add_child(ring)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(1.7, 1.7), 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.38)
	tween.chain().tween_callback(ring.queue_free)


static func button_pop(button: Control) -> void:
	button.pivot_offset = button.size * 0.5
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.98, 0.98), 0.045)
	tween.tween_property(button, "scale", Vector2(1.02, 1.02), 0.08)
	tween.tween_property(button, "scale", Vector2.ONE, 0.08)


static func hit_pause(node: Node, duration := 0.045) -> void:
	Engine.time_scale = 0.78
	var timer := node.get_tree().create_timer(duration, true, false, true)
	timer.timeout.connect(func(): Engine.time_scale = 1.0)


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
