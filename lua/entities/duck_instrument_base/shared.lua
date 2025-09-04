ENT.Base			= 'base_anim'
ENT.Type			= 'anim'
ENT.PrintName		= 'Instrument Base'
ENT.Category		= '#duckInstrument.Category'
ENT.DuckInstrument	= true

ENT.Model		= Model( 'models/fishy/furniture/piano.mdl' )
ENT.ChairModel	= Model( 'models/fishy/furniture/piano_seat.mdl' )
-- ENT.MaxKeys		= 4 -- how many keys can be played at once (depracted)
ENT.MaxDist		= 128 ^ 2	-- distance to use piano

ENT.ShowNoteEffect	= true	-- should we show note effect when key is pressed
ENT.NoteEffectSize	= 1		-- note effect size

ENT.SoundDir	= 'duckInstrument/piano/'
ENT.SoundExt 	= '.wav'

ENT.MidiCurrent = nil
ENT.MidiStartTime = nil

INSTNET_USE			= 1
INSTNET_HEAR		= 2
INSTNET_PLAY		= 3
INSTNET_MIDISTART	= 4
INSTNET_MIDISTOP	= 5
INSTNET_MIDISPAWN	= 6

-- ENT.Keys = {}
ENT.ControlKeys = {
	[KEY_TAB] =	function( inst, bPressed )
		if ( not bPressed ) then return end
		if inst.MidiCurrent then
			inst.MidiCurrent = nil
			inst.MidiStartTime = nil
			inst.MidiCurrentNote = 1

			RunConsoleCommand( 'duck_instrument_auto_stop' )

			return
		end
		RunConsoleCommand( 'duck_instrument_leave' )
	end,

	[KEY_SPACE] = function( inst, bPressed )
		if ( not bPressed ) then return end
		inst:ToggleSheetMusic()
	end,

	[KEY_LEFT] = function( inst, bPressed )
		if ( not bPressed ) then return end
		inst:SheetMusicBack()
	end,
	[KEY_RIGHT] = function( inst, bPressed )
		if ( not bPressed ) then return end
		inst:SheetMusicForward()
	end,
	[KEY_LALT] = function( inst, bPressed )
		if ( not bPressed ) then return end
		inst:MidiInterface()
	end,

	[KEY_LCONTROL] = function( inst, bPressed )
		inst:CtrlMod( bPressed )
	end,
	[KEY_RCONTROL] = function( inst, bPressed )
		inst:CtrlMod( bPressed )
	end,
	[KEY_LSHIFT] = function( inst, bPressed )
		inst:ShiftMod()
	end,
}

local validKeys = {}
do
	local files = file.Find("sound/" .. ENT.SoundDir .. "/*" .. ENT.SoundExt, "GAME")
	for i = 1, #files do
		local note = files[i]
		validKeys[string.sub(note, 1, #note - #ENT.SoundExt):lower()] = true
	end
end

function ENT:GetSound( snd )
	snd = snd:lower()
	if not snd then return end
	if snd == "" then return end
	if not validKeys[snd] then return end

	return self.SoundDir .. snd .. self.SoundExt
end

local keys = {
	C = 0,
	D = 2,
	E = 4,
	F = 6,
	G = 8,
	A = 10,
	B = 12,
}
function ENT:NoteEffect( key )
	if not self.ShowNoteEffect then return end

	local pos = keys[string.sub(key, 1, 1)]
	if string.match(key, '#') then
		pos = pos + 1

		local offset = tonumber( string.sub(key, 3, 4) )
		pos = pos + 12 * offset
	else
		local offset = tonumber( string.sub(key, 2, 3) )
		pos = pos + 12 * offset
	end
	pos = math.Remap(pos, 24, 84, -3.8, 4) * 10

	local offset = self:GetNoteEffectPos(pos)

	local effSize = self.NoteEffectSize or 1
	local eff = EffectData()
	eff:SetOrigin( self:GetPos() + offset )
	eff:SetScale(self.NoteEffectSize or 1)
	util.Effect( 'musicnotes', eff, true, true )
end

function ENT:GetNoteEffectPos(keyPos)
	local angle = self:GetAngles()
	return angle:Up() * 25 + angle:Forward() * 60 + angle:Right() * -(keyPos + 12)
end

function ENT:SetupDataTables()

	self:NetworkVar( 'Entity', 0, 'InstOwner' )

end

function ENT:CanUseAutoPlay(songId)
	local owner = self:GetInstOwner()

	if hook.Run("duckPiano.CanAutoPlay", self, owner, songId) == false then
		return false
	end

	return true
end

if SERVER then
	function ENT:Intiailize()
		self:PrecacheSounds()
	end

	function ENT:PrecacheSounds()

		if not self.Keys then return end

		for _, keyData in pairs( self.Keys ) do
			util.PrecacheSound( self:GetSound( keyData.Sound ) )
		end

	end
end

hook.Add( 'PhysgunPickup', 'NoPickupDuckInsturmentChair', function( ply, ent )

	local inst = ent:GetOwner()

	if IsValid( inst ) and inst.DuckInstrument then
		return false
	end

end )