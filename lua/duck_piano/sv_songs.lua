duckInstruments = {}
duckInstruments.songNames = {}

local function AddSong(n)
	if not isstring(n) then return end

	local i = #duckInstruments.songNames + 1
	duckInstruments.songNames[i] = n

	return i
end

function duckInstruments.GetSongName(id)
	return duckInstruments.songNames[id]
end

local function ReloadSongs()
	duckInstruments = {}
	duckInstruments.songNames = {}

	-- Разрешить добавление песен только из songs/*
	local songFiles, songFolders = file.Find('duck_piano/songs/*', 'LUA')
	duckInstruments.AddSong = AddSong

	for _,folder in pairs(songFolders) do
		local songFiles = file.Find( 'duck_piano/songs/' .. folder ..'/*', 'LUA' )
		for _,fileName in pairs(songFiles) do
			AddCSLuaFile('duck_piano/songs/' .. folder .. '/' .. fileName)
			include('duck_piano/songs/' .. folder .. '/' .. fileName)
		end
	end

	for _,fileName in pairs(songFiles) do
		AddCSLuaFile('duck_piano/songs/' .. fileName)
		include('duck_piano/songs/' .. fileName)
	end

	duckInstruments.AddSong = nil
end
ReloadSongs()

util.AddNetworkString("duck_piano_reload")
concommand.Add("duck_piano_reload", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	-- Не хотим путаницу с музыкой, так что сбросим это всё нафиг
	for _, ent in ents.Iterator() do
		if ent.Base == "duck_instrument_base" then
			ent.MidiCurrent = nil
			ent.MidiStartTime = nil

			net.Start("DuckInstrumentNetwork")
				net.WriteEntity(ent)
				net.WriteUInt(INSTNET_MIDISTOP, 3)
			net.Broadcast()
		end
	end

	ReloadSongs()
	print("[Duck Instruments] Registered " .. #duckInstruments.songNames .. " songs.")

	net.Start("duck_piano_reload")
	net.Broadcast()
end)
