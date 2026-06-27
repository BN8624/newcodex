# 로컬 저장 파일의 저장, 로드, 삭제를 담당하는 유틸리티
extends RefCounted
class_name SaveManager

const SAVE_PATH := "user://moonwell_vanguard_save.json"


static func save_game(state, path := SAVE_PATH) -> bool:
	state.last_play_time = Time.get_unix_time_from_system()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Save failed: " + path)
		return false
	file.store_string(JSON.stringify(state.to_save_dict()))
	return true


static func load_game(path := SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Load failed: " + path)
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


static func delete_save(path := SAVE_PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
