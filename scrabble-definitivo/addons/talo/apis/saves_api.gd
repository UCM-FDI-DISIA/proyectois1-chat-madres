class_name SavesAPI extends TaloAPI
## An interface for communicating with the Talo Saves API.
## This API permite crear, actualizar, eliminar y cargar partidas.

signal saves_loaded
signal save_chosen(save: TaloGameSave)
signal save_loading_completed
signal save_unloaded(save: TaloGameSave)

var _saves_manager := TaloSavesManager.new()

var all: Array[TaloGameSave]:
	get: return _saves_manager.all_saves

var latest: TaloGameSave:
	get: return _saves_manager.get_latest_save()

var current: TaloGameSave:
	get: return _saves_manager.current_save

func replace_save_with_offline_save(offline_save: TaloGameSave) -> TaloGameSave:
	var res := await client.make_request(HTTPClient.METHOD_PATCH, "/%s" % offline_save.id, {
		name = offline_save.name,
		content = offline_save.content
	})

	match res.status:
		200:
			return TaloGameSave.new(res.body.save)
		_:
			return null

func get_saves() -> Array[TaloGameSave]:
	var saves: Array[TaloGameSave] = []
	var offline_saves: Array[TaloGameSave] = _saves_manager.read_offline_saves()
	var online_saves: Array[TaloGameSave] = []

	if await Talo.is_offline():
		print("Hay partida guardada")
	else:
		if Talo.identity_check() != OK:
			print("No hay partida guardada")

		var res := await client.make_request(HTTPClient.METHOD_GET, "/")
		match res.status:
			200:
				online_saves.append_array(res.body.saves.map(func (data: Dictionary): return TaloGameSave.new(data)))
				var synced_saves := await _saves_manager.get_synced_saves(online_saves)
				saves.append_array(synced_saves)
	
	_saves_manager.all_saves = saves
	saves_loaded.emit()
	return _saves_manager.all_saves

func choose_save(save: TaloGameSave, load_save = true) -> void:
	_saves_manager.set_chosen_save(save, load_save)

func unload_current_save() -> void:
	if current:
		save_unloaded.emit(current)
	_saves_manager.unload_current_save()

func create_save(save_name: String, content: Dictionary = {}) -> TaloGameSave:
	var save: TaloGameSave
	var save_content := content if not content.is_empty() else _saves_manager.get_save_content()

	if await Talo.is_offline():
		save = TaloGameSave.new({
			name = save_name,
			content = save_content,
			updatedAt = TaloTimeUtils.get_current_datetime_string()
		})
	else:
		var res := await client.make_request(HTTPClient.METHOD_POST, "/", {
			name = save_name,
			content = save_content
		})
		match res.status:
			200:
				save = TaloGameSave.new(res.body.save)
		
	_saves_manager.all_saves.push_back(save)
	choose_save(save)
	return save

func register(loadable: TaloLoadable) -> void:
	_saves_manager.register(loadable)

func update_current_save(new_name: String = "") -> TaloGameSave:
	return await update_save(_saves_manager.current_save, new_name)

func update_save(save: TaloGameSave, new_name: String = "") -> TaloGameSave:
	var content := _saves_manager.get_save_content()

	if await Talo.is_offline():
		if not new_name.is_empty():
			save.name = new_name
		save.content = content
		save.updated_at = TaloTimeUtils.get_current_datetime_string()
	else:
		if Talo.identity_check() != OK:
			return

		var res := await client.make_request(HTTPClient.METHOD_PATCH, "/%s" % save.id, {
			name=save.name if new_name.is_empty() else new_name,
			content=content
		})
		match res.status:
			200:
				save = TaloGameSave.new(res.body.save)

	_saves_manager.replace_save(save)
	return save

func delete_save(save: TaloGameSave, unload_if_current_save: bool = false) -> void:
	if not await Talo.is_offline():
		if Talo.identity_check() != OK:
			return
		var res := await client.make_request(HTTPClient.METHOD_DELETE, "/%s" % save.id)
		if res.status != 204:
			return
	
	_saves_manager.all_saves = _saves_manager.all_saves.filter(func (s: TaloGameSave): s.id != save.id)

	var is_current_save := _saves_manager.current_save and _saves_manager.current_save.id == save.id
	if unload_if_current_save and is_current_save:
		unload_current_save()

func get_format_version() -> String:
	return _saves_manager.get_format_version()
