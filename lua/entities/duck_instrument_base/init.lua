AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

util.AddNetworkString( 'DuckInstrumentNetwork' )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:DrawShadow( true )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end

	self:InitializeAfter()

end

function ENT:InitializeAfter()
end

local function HandleRollercoasterAnimation( vehicle, player )
	return player:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER )
end

function ENT:SetupChair( vecmdl, angmdl, vecvehicle, angvehicle )

	-- Chair Model
	self.ChairMDL = ents.Create( 'prop_physics_multiplayer' )
	self.ChairMDL:SetModel( self.ChairModel )
	self.ChairMDL:SetParent( self )
	self.ChairMDL:SetPos( self:GetPos() + vecmdl )
	self.ChairMDL:SetAngles( angmdl )
	self.ChairMDL:DrawShadow( false )

	self.ChairMDL:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self.ChairMDL:Spawn()
	self.ChairMDL:Activate()
	self.ChairMDL:SetOwner( self )

	local phys = self.ChairMDL:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

	self.ChairMDL:SetKeyValue( 'minhealthdmg', '999999' )

	-- Chair Vehicle
	self.Chair = ents.Create( 'prop_vehicle_prisoner_pod' )
	self.Chair:SetModel( 'models/nova/airboat_seat.mdl' )
	self.Chair:SetKeyValue( 'vehiclescript','scripts/vehicles/prisoner_pod.txt' )
	self.Chair:SetPos( self.ChairMDL:GetPos() + vecvehicle )
	self.Chair:SetParent( self.ChairMDL )
	self.Chair:SetAngles( angvehicle )
	self.Chair:SetNotSolid( true )
	self.Chair:SetNoDraw( true )
	self.Chair:DrawShadow( false )
	self.Chair:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self.Chair.HandleAnimation = HandleRollercoasterAnimation
	self.Chair:SetOwner( self )
	self.Chair.DuckInstrumentChair = true

	self.Chair:Spawn()
	self.Chair:Activate()

	phys = self.Chair:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

end

local function HookChair( ply, ent )

	local inst = ent:GetOwner()

	if IsValid( inst ) and inst.DuckInstrument then

		if not IsValid( inst:GetInstOwner() ) then
			inst:AddOwner( ply )
			return true
		else
			if inst:GetInstOwner() == ply then
				return true
			end
		end

		return false

	end

	return true

end

-- Quick fix for overriding the instrument chair seating
hook.Add( 'CanPlayerEnterVehicle', 'DuckInstrumentChairHook', HookChair )
hook.Add( 'PlayerUse', 'DuckInstrumentChairModelHook', HookChair )

function ENT:Use( ply )

	if IsValid( self:GetInstOwner() ) then return end

	self:AddOwner( ply )

end

function ENT:AddOwner( ply )

	if IsValid( self:GetInstOwner() ) then return end

	net.Start( 'DuckInstrumentNetwork' )
		net.WriteEntity( self )
		net.WriteUInt( INSTNET_USE, 3 )
	net.Send( ply )

	ply.EntryPoint = ply:GetPos() - self:GetPos()
	ply.EntryAngles = ply:EyeAngles()
	ply.DuckInstrument = self

	self:SetInstOwner(ply)

	ply:EnterVehicle( self.Chair )

	self:GetInstOwner():SetEyeAngles( Angle( 25, 90, 0 ) )

end

function ENT:RemoveOwner()

	if not IsValid( self:GetInstOwner() ) then return end

	local ply = self:GetInstOwner()

	self:SetInstOwner(NULL)

	net.Start( 'DuckInstrumentNetwork' )
		net.WriteEntity( nil )
		net.WriteUInt( INSTNET_USE, 3 )
	net.Send( ply )

	ply:ExitVehicle( self.Chair )

	ply:SetPos( ply.EntryPoint + self:GetPos() )
	ply:SetEyeAngles( ply.EntryAngles )
	ply.DuckInstrument = nil

	self.MidiCurrent = nil
	self.MidiStartTime = nil

	net.Start( 'DuckInstrumentNetwork' )
		net.WriteEntity( self )
		net.WriteUInt( INSTNET_MIDISTOP, 3 )
	net.Broadcast()

end

--[[ function ENT:NetworkKeys( keys )

	if not IsValid( self:GetInstOwner() ) then return end -- no reason to broadcast it

	net.Start( 'DuckInstrumentNetwork' )

		net.WriteEntity( self )
		net.WriteUInt( INSTNET_HEAR, 3 )
		net.WriteTable( keys )

	net.Broadcast()

end ]]

function ENT:NetworkKey( key )

	if not IsValid( self:GetInstOwner() ) then return end -- no reason to broadcast it

	net.Start( 'DuckInstrumentNetwork' )

		net.WriteEntity( self )
		net.WriteUInt( INSTNET_HEAR, 3 )
		net.WriteString( key )

	net.Broadcast()

end

net.Receive( 'DuckInstrumentNetwork', function( length, client )

	local ent = net.ReadEntity()
	if not IsValid( ent ) then return end

	local enum = net.ReadUInt( 3 )

	-- When the player plays notes
	if enum == INSTNET_PLAY then

		-- Filter out non-instruments
		if not ent.DuckInstrument then return end

		-- This instrument doesn't have an owner...
		if not IsValid( ent:GetInstOwner() ) then return end

		-- Check if the player is actually the owner of the instrument
		if client ~= ent:GetInstOwner() then return end

		-- Gather note
		local key = net.ReadString()

		-- Send it!!
		ent:NetworkKey( key )

		-- Effects
		ent:NoteEffect( key )

		-- Gather notes
		--[[ local keys = net.ReadTable()
	
		-- Send them!!
		ent:NetworkKeys( keys ) ]]

	elseif enum == INSTNET_MIDISTART then

		-- Filter out non-instruments
		if not ent.DuckInstrument then return end

		-- This instrument doesn't have an owner...
		if not IsValid( ent:GetInstOwner() ) then return end

		-- Check if the player is actually the owner of the instrument
		if client ~= ent:GetInstOwner() then return end

		-- Check if the player can auto-play
		if not ent:CanUseAutoPlay() then return end

		ent.MidiCurrent = net.ReadUInt(7)
		ent.MidiStartTime = CurTime()

		net.Start('DuckInstrumentNetwork')
			net.WriteEntity( ent )
			net.WriteUInt( INSTNET_MIDISTART, 3 )
			net.WriteUInt( ent.MidiCurrent, 7 )
			net.WriteDouble( ent.MidiStartTime )
		net.Broadcast()

	elseif enum == INSTNET_MIDISPAWN then

		-- Filter out non-instruments
		if not ent.DuckInstrument then return end

		-- This instrument doesn't have an owner...
		if not IsValid( ent:GetInstOwner() ) then return end

		net.Start('DuckInstrumentNetwork')
			net.WriteEntity( ent )
			net.WriteUInt( INSTNET_MIDISTART, 3 )
			net.WriteUInt( ent.MidiCurrent, 7 )
			net.WriteDouble( ent.MidiStartTime )
		net.Broadcast()

	end

end )

concommand.Add( 'duck_instrument_leave', function( ply, cmd, args )

	if #args < 1 then return end -- no ent id

	-- Get the instrument
	local entid = args[1]
	local ent = ents.GetByIndex( entid )

	-- Filter out non-instruments
	if not IsValid( ent ) or not ent.DuckInstrument then return end

	-- This instrument doesn't have an owner...
	if not IsValid( ent:GetInstOwner() ) then return end

	-- Leave instrument
	if ply ~= ent:GetInstOwner() then return end

	ent:RemoveOwner()

end )

concommand.Add( 'duck_instrument_auto_stop', function( ply, cmd, args )

	if #args < 1 then return end -- no ent id

	-- Get the instrument
	local entid = args[1]
	local ent = ents.GetByIndex( entid )

	-- Filter out non-instruments
	if not IsValid( ent ) or not ent.DuckInstrument then return end

	-- This instrument doesn't have an owner...
	if not IsValid( ent:GetInstOwner() ) then return end

	-- Leave instrument
	if ply ~= ent:GetInstOwner() then return end

	ent.MidiCurrent = nil
	ent.MidiStartTime = nil

	net.Start( 'DuckInstrumentNetwork' )
		net.WriteEntity( ent )
		net.WriteUInt( INSTNET_MIDISTOP, 3 )
	net.Broadcast()

end )

local function leaveInst(ply)
	local inst = ply.DuckInstrument
	if not IsValid(inst) then return end

	inst:RemoveOwner()
end
hook.Add( 'PlayerDisconnected', 'DuckInstrument', leaveInst )

hook.Add( 'PlayerLeaveVehicle', 'DuckInstrument', function( ply, veh )
	if not veh.DuckInstrumentChair then return end

	leaveInst(ply)
end )