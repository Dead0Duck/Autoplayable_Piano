local songsPath = "data_static/duck_instrument/songs/"

local indexToNote = {}
do
	local noteNames = {
		"A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"
	}

	local index = 0

	for i = 1, 3 do
		indexToNote[index] = noteNames[i] .. "0"
		index = index + 1
	end

	for octave = 1, 7 do
		for i = 1, 12 do
			indexToNote[index] = noteNames[i] .. octave
			index = index + 1
		end
	end

	indexToNote[index] = "C8"
end

local function ReadNullTerminatedString(fileHandle)
	local startPos = fileHandle:Tell()
	
	local chunk = fileHandle:Read(4096)
	if not chunk then return "" end
	
	local nullPos = chunk:find("\0")
	if nullPos then
		fileHandle:Seek(startPos + nullPos)
		return chunk:sub(1, nullPos - 1)
	else
		return chunk
	end
end

local function OpenFile(path)
	local f = file.Open(songsPath .. path, "rb", "GAME")
	if not f then return end

	if f:Read(13) ~= "DuckInstSong\0" then
		print(Format("[Duck Instruments] Error while loading!\nFile \"%s\" is not a Duck Instrument song file", path))
		f:Close()
		return
	end

	local version = f:ReadShort()
	if version ~= 2 then		-- Пока мы имеем только 1 версию файла, мы можем такое себе позволить
		print(Format("[Duck Instruments] Error while loading!\nFile \"%s\" has unknown format version", path))
		f:Close()
		return
	end

	return f
end

function duckInstruments.ReadName(path)
	local f = OpenFile(path)
	if not f then return end

	local songName = ReadNullTerminatedString(f)
	f:Close()

	return songName
end

function duckInstruments.ReadFull(path)
	local f = OpenFile(path)
	if not f then return end

	local songName = ReadNullTerminatedString(f)
	local songCover = nil
	if f:ReadBool() then
		songCover = ReadNullTerminatedString(f)
	end

	local data = {}
	while not f:EndOfFile() do
		local noteInd = f:ReadByte()
		if not noteInd or not indexToNote[noteInd] then break end

		local noteTime = f:ReadDouble()
		if not noteTime then break end

		data[#data + 1] = indexToNote[noteInd]
		data[#data + 1] = noteTime
	end

	return {songName, songCover, data}
end

function duckInstruments.ReadNotes(path)
	local f = OpenFile(path)
	if not f then return end

	ReadNullTerminatedString(f)
	if f:ReadBool() then
		ReadNullTerminatedString(f)
	end

	local data = {}
	while not f:EndOfFile() do
		local noteInd = f:ReadByte()
		if not noteInd or not indexToNote[noteInd] then break end

		local noteTime = f:ReadDouble()
		if not noteTime then break end

		data[#data + 1] = indexToNote[noteInd]
		data[#data + 1] = noteTime
	end

	return data
end
