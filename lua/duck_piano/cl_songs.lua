duckInstruments = {}
duckInstruments.songs = {}
duckInstruments.songNames = {}
duckInstruments.songCovers = {}

local curCover

local function AddSong(n, v)
	if not isstring(n) then return end
	if not istable(v) then return end

	local i = #duckInstruments.songs + 1
	duckInstruments.songs[i] = v
	duckInstruments.songNames[i] = n
	duckInstruments.songCovers[i] = curCover

	return i
end

local function SetCover(cover)
	curCover = cover or nil
end

function duckInstruments.GetSongName(id)
	return duckInstruments.songNames[id]
end

local function ReloadSongs()
	duckInstruments.songs = {}
	duckInstruments.songNames = {}
	duckInstruments.songCovers = {}

	-- Разрешить добавление песен только из songs/*
	local songFiles, songFolders = file.Find('duck_piano/songs/*', 'LUA')
	duckInstruments.AddSong = AddSong
	duckInstruments.SetCover = SetCover

	for _,folder in pairs(songFolders) do
		local songFiles = file.Find( 'duck_piano/songs/' .. folder ..'/*', 'LUA' )
		for _,fileName in pairs(songFiles) do
			curCover = nil
			include('duck_piano/songs/' .. folder .. '/' .. fileName)
		end
	end

	for _,fileName in pairs(songFiles) do
		curCover = nil
		include('duck_piano/songs/' .. fileName)
	end

	curCover = nil
	duckInstruments.AddSong = nil
	duckInstruments.SetCover = nil
end
ReloadSongs()

net.Receive("duck_piano_reload", function()
	ReloadSongs()
	print("[Duck Instruments] Registered " .. #duckInstruments.songNames .. " songs.")
end)
