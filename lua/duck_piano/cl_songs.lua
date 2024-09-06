duckInstruments = {}
duckInstruments.songs = {}
duckInstruments.songNames = {}

local function AddSong(n, v)
	local i = #duckInstruments.songs + 1
	duckInstruments.songs[i] = v
	duckInstruments.songNames[i] = n
end

-- Разрешить добавление песен только из songs/*
local songFiles, songFolders = file.Find('duck_piano/songs/*', 'LUA')
duckInstruments.AddSong = AddSong

for _,folder in pairs(songFolders) do
	local songFiles = file.Find( 'duck_piano/songs/' .. folder ..'/*', 'LUA' )
	for _,fileName in pairs(songFiles) do
		include('duck_piano/songs/' .. folder .. '/' .. fileName)
	end
end

for _,fileName in pairs(songFiles) do
	include('duck_piano/songs/' .. fileName)
end

duckInstruments.AddSong = nil
