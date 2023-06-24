duckInstruments = {}
duckInstruments.songs = {}
duckInstruments.songNames = {}

function duckInstruments.AddSong(n, v)
	local i = #duckInstruments.songs + 1
	duckInstruments.songs[i] = v
	duckInstruments.songNames[i] = n
end

local songFiles = file.Find( 'duck_piano/songs/*', 'LUA' )
for _,fileName in pairs(songFiles) do
	include('duck_piano/songs/' .. fileName)
end