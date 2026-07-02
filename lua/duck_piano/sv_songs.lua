duckInstruments = {}
duckInstruments.songNames = {}

if game.SinglePlayer() then
	include("sv_migrator.lua")
end
include("sh_reader_v2.lua")

local songsPath = "data_static/duck_instrument/songs/"

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
	local songFiles, songFolders = file.Find(songsPath .. "*", "GAME")

	duckInstruments.songNames = {}

	for _,folder in pairs(songFolders) do
		local songFiles = file.Find(songsPath .. folder .."/*", "GAME")
		for _,fileName in pairs(songFiles) do
			local songName = duckInstruments.ReadName(folder .."/" .. fileName)
			AddSong(songName)
		end
	end

	for _,fileName in pairs(songFiles) do
		local songName = duckInstruments.ReadName(fileName)
		AddSong(songName)
	end

	print("[Duck Instruments] Registered " .. #duckInstruments.songNames .. " songs.")
end
ReloadSongs()

util.AddNetworkString("duck_piano_reload")
concommand.Add("duck_piano_reload", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	-- Не хотим путаницу с музыкой, так что сбросим это всё нафиг
	for _, ent in ents.Iterator() do
		if ent.IsDuckInstrument then
			ent.MidiCurrent = nil
			ent.MidiStartTime = nil

			net.Start("DuckInstrumentNetwork")
				net.WriteEntity(ent)
				net.WriteUInt(INSTNET_MIDISTOP, 3)
			net.Broadcast()
		end
	end

	ReloadSongs()

	net.Start("duck_piano_reload")
	net.Broadcast()
end)
