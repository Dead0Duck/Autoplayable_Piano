local IsLocalGame = game.SinglePlayer()

local function EmptyFunc()
end

local curCover
local curSource

local function AddSong(n, v)
	if not isstring(n) then return end
	if not isstring(v) and not istable(v) then return end

	local i = #duckInstruments.songs + 1
	duckInstruments.songs[i] = v
	duckInstruments.songNames[i] = n
	duckInstruments.songCovers[i] = curCover
	duckInstruments.songDuration[i] = v[#v]
	duckInstruments.songNotesCount[i] = #v / 2
	if IsLocalGame then
		duckInstruments.songSources[i] = curSource
	end

	return i
end

local function SetCover(cover)
	curCover = cover or nil
end

local addns = engine.GetAddons()
local function GetFileOrigin(path)
	print(path)
	for i = 1, #addns do
		if file.Exists(path, addns[i].title) then
			return addns[i].title
		end
	end
end

-- На выделенных серверах все файлы будут "Локальными аддонами", так что выпиливаем это вобще
if not IsLocalGame then
	GetFileOrigin = EmptyFunc
	SetSource = EmptyFunc
	duckInstruments.songSources = nil
end

local function LoadSongsV1()
	-- Разрешить добавление песен только из songs/*
	local songFiles, songFolders = file.Find('duck_piano/songs/*', 'LUA')
	duckInstruments.AddSong = AddSong
	duckInstruments.SetCover = SetCover
	duckInstruments.SetSource = SetSource

	for _,folder in pairs(songFolders) do
		local songFiles = file.Find( 'duck_piano/songs/' .. folder ..'/*', 'LUA' )
		for _,fileName in pairs(songFiles) do
			curCover = nil
			curSource = GetFileOrigin('lua/duck_piano/songs/' .. folder .. '/' .. fileName)
			include('duck_piano/songs/' .. folder .. '/' .. fileName)
		end
	end

	for _,fileName in pairs(songFiles) do
		curCover = nil
		curSource = GetFileOrigin('lua/duck_piano/songs/' .. fileName)
		include('duck_piano/songs/' .. fileName)
	end

	curCover = nil
	duckInstruments.AddSong = nil
	duckInstruments.SetCover = nil
	duckInstruments.SetSource = nil
end

return LoadSongsV1
