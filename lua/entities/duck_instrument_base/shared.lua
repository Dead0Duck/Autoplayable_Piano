ENT.Base			= 'base_anim'
ENT.Type			= 'anim'
ENT.PrintName		= 'Instrument Base'
ENT.Category		= '#duckInstrument.Category'
ENT.DuckInstrument	= true

ENT.Model		= Model( 'models/fishy/furniture/piano.mdl' )
ENT.ChairModel	= Model( 'models/fishy/furniture/piano_seat.mdl' )
ENT.MaxKeys		= 4 -- how many keys can be played at once

ENT.SoundDir	= 'GModTower/lobby/instruments/piano/'
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

			RunConsoleCommand( 'duck_instrument_auto_stop', inst:EntIndex() )

			return
		end
		RunConsoleCommand( 'duck_instrument_leave', inst:EntIndex() )
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

function ENT:GetSound( snd )

	if ( snd == nil or snd == '' ) then
		return nil
	end

	return self.SoundDir .. snd .. self.SoundExt
end

-- Returns the approximate 'fitted' number based on linear regression.
function math.Fit( val, valMin, valMax, outMin, outMax )
	return ( val - valMin ) * ( outMax - outMin ) / ( valMax - valMin ) + outMin
end

function ENT:NoteEffect( key )
	local pos = string.sub( key, 2, 3 )
	pos = math.Fit( tonumber( pos ), 1, 36, -3.8, 4 ) * 10

	local angle = self:GetAngles()
	local offset = angle:Up() * 25 + angle:Forward() * 60 + angle:Right() * -(pos + 12)

	local eff = EffectData()
	eff:SetOrigin( self:GetPos() + offset )
	util.Effect( 'musicnotes', eff, true, true )
end

function ENT:SetupDataTables()

	self:NetworkVar( 'Entity', 0, 'InstOwner' )

end

function ENT:CanUseAutoPlay()
	local owner = self:GetInstOwner()

	if hook.Run("duckPiano.CanAutoPlay", self, owner) == false then
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