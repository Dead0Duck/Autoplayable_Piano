local IsLocalGame = game.SinglePlayer()

duckInstruments = {}
duckInstruments.songs = {}
duckInstruments.songNames = {}
duckInstruments.songCovers = {}
duckInstruments.songSources = {}

local function EmptyFunc()
end

local curCover
local curSource

local function AddSong(n, v)
	if not isstring(n) then return end
	if not istable(v) then return end

	local i = #duckInstruments.songs + 1
	duckInstruments.songs[i] = v
	duckInstruments.songNames[i] = n
	duckInstruments.songCovers[i] = curCover
	if IsLocalGame then
		duckInstruments.songSources[i] = curSource
	end

	return i
end

local function SetCover(cover)
	curCover = cover or nil
end

local function SetSource(source)
	curSource = source or nil
end

function duckInstruments.GetSongName(id)
	return duckInstruments.songNames[id]
end

function duckInstruments.GetSongCover(id)
	return duckInstruments.songCovers[id]
end

function duckInstruments.GetSongNotesCount(id)
	return duckInstruments.songs[id] and #duckInstruments.songs[id] / 2
end

function duckInstruments.GetSongDuration(id)
	local song = duckInstruments.songs[id]
	return song and song[#song]
end


local addns = engine.GetAddons()
local function GetFileOrigin(path)
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

local function ReloadSongs()
	duckInstruments.songs = {}
	duckInstruments.songNames = {}
	duckInstruments.songCovers = {}
	if IsLocalGame then
		duckInstruments.songSources = {}
	end

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
	duckInstruments.AddSong = EmptyFunc
	duckInstruments.SetCover = EmptyFunc
	duckInstruments.SetSource = EmptyFunc
end
ReloadSongs()

net.Receive("duck_piano_reload", function()
	ReloadSongs()
	print("[Duck Instruments] Registered " .. #duckInstruments.songNames .. " songs.")
end)
