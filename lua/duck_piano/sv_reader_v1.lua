local function AddSong(n)
	if not isstring(n) then return end

	local i = #duckInstruments.songNames + 1
	duckInstruments.songNames[i] = n

	return i
end

local function EmptyFunc()
end

local function LoadSongsV1()
	-- Разрешить добавление песен только из songs/*
	local songFiles, songFolders = file.Find('duck_piano/songs/*', 'LUA')
	duckInstruments.AddSong = AddSong
	duckInstruments.SetCover = EmptyFunc
	duckInstruments.SetSource = EmptyFunc

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
	duckInstruments.SetCover = nil
	duckInstruments.SetSource = nil
end

return LoadSongsV1
