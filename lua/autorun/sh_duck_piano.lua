if SERVER then
	AddCSLuaFile('duck_piano/cl_songs.lua')
	include('duck_piano/sv_songs.lua')
end

if CLIENT then
	include('duck_piano/cl_songs.lua')
end
