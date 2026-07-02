local noteToIndex = {}

local function EmptyFunc()
end

local function SanitizeFileName(filename)
	if not filename or filename == "" then
		return "song_" .. os.time()
	end

	local sanitized = filename

	-- 1. Приводим к lowercase (рекомендуется для стабильности)
	sanitized = sanitized:lower()

	-- 2. Заменяем всё опасное на подчёркивание
	-- Разрешены только: a-z, 0-9, _, -, .
	sanitized = sanitized:gsub("[^a-z0-9._-]", "_")

	-- 3. Убираем опасные последовательности
	sanitized = sanitized:gsub("%.%.", "_")           -- ".."
	sanitized = sanitized:gsub("%-%-", "_")           -- "--"
	sanitized = sanitized:gsub("__+", "_")            -- множественные _
	sanitized = sanitized:gsub("%._", "_")            -- "._"
	sanitized = sanitized:gsub("_%.", "_")            -- "_."
	sanitized = sanitized:gsub("^%._", "")            -- "._" в начале
	sanitized = sanitized:gsub("%.$", "")             -- точка в конце

	-- 4. Убираем начальные и конечные _ и -
	sanitized = sanitized:gsub("^[_-]+", "")
	sanitized = sanitized:gsub("[_-]+$", "")

	-- 5. Если после очистки ничего не осталось
	if sanitized == "" or sanitized == "." or sanitized == "-" then
		return "song_" .. os.time()
	end

	-- 6. Ограничиваем длину
	if #sanitized > 120 then
		sanitized = sanitized:sub(1, 120)
	end

	-- 7. Добавляем .dat в конце, если нет расширения
	if not sanitized:match("%.dat$") then
		sanitized = sanitized .. ".dat"
	end

	return sanitized
end

do
	local noteNames = {
		"A", "A#", "B",
		"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"
	}

	local index = 0

	for i = 1, 3 do
		noteToIndex[noteNames[i] .. "0"] = index
		index = index + 1
	end

	for octave = 1, 7 do
		for _, name in ipairs(noteNames) do
			noteToIndex[name .. octave] = index
			index = index + 1
		end
	end

	noteToIndex["C8"] = index
end

local function MigrateSongs()
	print("[Duck Instrument] Starting migration...")
	file.CreateDir("duck_instument/migrate")

	local fold = ""
	local cover = ""

	duckInstruments.SetCover = function(newCover)
		cover = newCover
	end

	duckInstruments.SetSource = EmptyFunc

	local songFiles, songFolders = file.Find("duck_piano/songs/*", "LUA")
	duckInstruments.AddSong = function(name, data)
		if fold ~= "" then
			file.CreateDir("duck_instument/migrate/" .. fold)
		end

		local fName = SanitizeFileName(name)
		local f = file.Open("duck_instument/migrate/" .. fold .. "/" .. fName, "wb", "DATA")
		if not f then print(Format("[Duck Instrument] We tried our best, but we can't create a file for a song called \"%s\", please change its name and try again", name)) return end

		f:Write("DuckInstSong\0")		-- Header
		f:WriteShort(2)				-- Format Version
		f:Write(name .. "\0")			-- Song Name

		if cover == "" then
			f:WriteBool(false)
		else
			f:WriteBool(true)
			f:Write(cover .. "\0")
		end

		for i = 1, #data, 2 do
			local note = data[i]
			local time = data[i + 1]

			local noteInd = noteToIndex[note]
			if not noteInd then
				continue
			end

			f:WriteByte(noteInd)
			f:WriteDouble(time)
		end

		f:Close()
	end

	for _,folder in pairs(songFolders) do
		fold = folder
		local songFiles = file.Find( "duck_piano/songs/" .. folder .."/*", "LUA" )
		for _,fileName in pairs(songFiles) do
			include("duck_piano/songs/" .. folder .. "/" .. fileName)
			cover = ""
		end
	end

	fold = ""
	for _,fileName in pairs(songFiles) do
		include("duck_piano/songs/" .. fileName)
		cover = ""
	end

	duckInstruments.AddSong = EmptyFunc
	duckInstruments.SetCover = EmptyFunc

	print("[Duck Instrument] Migration completed!\nYou can find files in your gmod installation folder inside \"\\garrysmod\\data\\duck_instument\\migrate\\\"")
end

concommand.Add("duck_piano_migrate", function(ply)
	MigrateSongs()
end)
