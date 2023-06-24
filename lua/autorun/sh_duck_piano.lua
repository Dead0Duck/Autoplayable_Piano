if SERVER then
	AddCSLuaFile('duck_piano/cl_songs.lua')

	local songFiles = file.Find( 'duck_piano/songs/*', 'LUA' )
	for _,fileName in pairs(songFiles) do
		AddCSLuaFile('duck_piano/songs/' .. fileName)
	end
end

if CLIENT then
	include('duck_piano/cl_songs.lua')
end