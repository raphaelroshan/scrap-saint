extends RefCounted
## Atomic Variant persistence with one last-known-good backup.

const TEMP_SUFFIX = ".tmp"
const BACKUP_SUFFIX = ".bak"

# Deterministic fault injection for persistence tests. Production leaves this false.
var fail_before_replace = false

func write_atomic(path: String, value) -> bool:
	var primary = ProjectSettings.globalize_path(path)
	var temporary = primary + TEMP_SUFFIX
	var backup = primary + BACKUP_SUFFIX
	_remove_if_file(temporary)
	var file = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return false
	file.store_var(value)
	file.flush()
	file = null
	if not _read_dictionary(temporary).has_value: 
		_remove_if_file(temporary)
		return false
	if fail_before_replace:
		_remove_if_file(temporary)
		return false
	if FileAccess.file_exists(primary):
		_remove_if_file(backup)
		if DirAccess.rename_absolute(primary, backup) != OK:
			_remove_if_file(temporary)
			return false
	if DirAccess.rename_absolute(temporary, primary) != OK:
		if not FileAccess.file_exists(primary) and FileAccess.file_exists(backup):
			DirAccess.rename_absolute(backup, primary)
		_remove_if_file(temporary)
		return false
	return true

func load_dictionary(path: String) -> Dictionary:
	var candidates = load_dictionaries(path)
	return candidates[0] if not candidates.is_empty() else {}

func load_dictionaries(path: String) -> Array:
	var primary = ProjectSettings.globalize_path(path)
	var candidates: Array = []
	for candidate in [primary, primary + BACKUP_SUFFIX]:
		var loaded = _read_dictionary(candidate)
		if loaded.has_value: candidates.append(loaded.value)
	return candidates

func has_valid_save(path: String) -> bool:
	return not load_dictionary(path).is_empty()

func clear(path: String):
	var primary = ProjectSettings.globalize_path(path)
	for candidate in [primary, primary + TEMP_SUFFIX, primary + BACKUP_SUFFIX]:
		_remove_if_file(candidate)

func _read_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {"has_value": false}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null: return {"has_value": false}
	var value = file.get_var(false)
	return {"has_value": value is Dictionary, "value": value}

func _remove_if_file(path: String):
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
