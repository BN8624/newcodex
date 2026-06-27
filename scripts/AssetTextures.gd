# PNG 에셋을 import 상태와 무관하게 Texture2D로 읽어오는 로더
extends RefCounted
class_name AssetTextures


static func load_png(path: String) -> Texture2D:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			return resource
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	var err := image.load(path)
	if err != OK:
		push_warning("PNG load failed: " + path)
		return null
	var texture := ImageTexture.create_from_image(image)
	return texture
