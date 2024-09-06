if SERVER then
	AddCSLuaFile('duck_piano/cl_songs.lua')

	local songFiles, songFolders = file.Find( 'duck_piano/songs/*', 'LUA' )
	for _,folder in pairs(songFolders) do
		local songFiles = file.Find( 'duck_piano/songs/' .. folder ..'/*', 'LUA' )
		for _,fileName in pairs(songFiles) do
			AddCSLuaFile('duck_piano/songs/' .. folder .. '/' .. fileName)
		end
	end
	for _,fileName in pairs(songFiles) do
		AddCSLuaFile('duck_piano/songs/' .. fileName)
	end
end

if CLIENT then
	include('duck_piano/cl_songs.lua')
end
