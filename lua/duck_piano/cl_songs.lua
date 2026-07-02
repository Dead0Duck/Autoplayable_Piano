local IsLocalGame = game.SinglePlayer()

duckInstruments = {}

local function ResetData()
	duckInstruments.songs = {}
	duckInstruments.songNames = {}
	duckInstruments.songCovers = {}
	duckInstruments.songSources = IsLocalGame and {} or nil
	duckInstruments.songDuration = {}
	duckInstruments.songNotesCount = {}
end
ResetData()

local songsPath = "data_static/duck_instrument/songs/"
include("sh_reader_v2.lua")

local function EmptyFunc()
end

local curCover
local curSource
local curDur = 0
local curCount = 0

local function AddSong(n, v)
	if not isstring(n) then return end
	if not isstring(v) and not istable(v) then return end

	local i = #duckInstruments.songs + 1
	duckInstruments.songs[i] = v
	duckInstruments.songNames[i] = n
	duckInstruments.songCovers[i] = curCover
	duckInstruments.songDuration[i] = curDur
	duckInstruments.songNotesCount[i] = curCount
	if IsLocalGame then
		duckInstruments.songSources[i] = curSource
	end

	return i
end

local function SetCover(cover)
	curCover = cover or nil
end

local function SetDuration(dur)
	curDur = dur or 0
end

local function SetNotesCount(count)
	curCount = count or 0
end

function duckInstruments.GetSongName(id)
	return duckInstruments.songNames[id]
end

function duckInstruments.GetSongCover(id)
	return duckInstruments.songCovers[id]
end

function duckInstruments.GetSongDuration(id)
	return duckInstruments.songDuration[id]
end

function duckInstruments.GetSongNotesCount(id)
	return duckInstruments.songNotesCount[id]
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
	duckInstruments.songSources = nil
end

local function ReadFile(path)
	local data = duckInstruments.ReadFull(path)
	local notes = data[3]

	SetNotesCount(#notes / 2)
	SetDuration(notes[#notes])
	SetCover(data[2])

	AddSong(data[1], path)
end
local function ReloadSongs()
	local songFiles, songFolders = file.Find(songsPath .. "*", "GAME")

	ResetData()

	for _,folder in pairs(songFolders) do
		local songFiles = file.Find(songsPath .. folder .."/*", "GAME")
		for _,fileName in pairs(songFiles) do
			curSource = GetFileOrigin(folder .."/" .. fileName)
			ReadFile(folder .."/" .. fileName)
		end
	end

	for _,fileName in pairs(songFiles) do
		curSource = GetFileOrigin(fileName)
		ReadFile(fileName)
	end
end
ReloadSongs()

net.Receive("duck_piano_reload", function()
	ReloadSongs()
	print("[Duck Instruments] Registered " .. #duckInstruments.songNames .. " songs.")
end)
