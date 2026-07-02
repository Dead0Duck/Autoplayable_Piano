if SERVER then
	AddCSLuaFile("skins/dd_instruments.lua")
	AddCSLuaFile("duck_piano/cl_songs.lua")
	AddCSLuaFile("duck_piano/sh_reader_v2.lua")
	include("duck_piano/sv_songs.lua")
end

if CLIENT then
	include("skins/dd_instruments.lua")
	include("duck_piano/cl_songs.lua")
end
