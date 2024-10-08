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
	local isNewChair = false
	if not IsValid(self.ChairMDL) or self.ChairMDL:GetOwner() ~= self then
		isNewChair = true
		self.ChairMDL = ents.Create( 'prop_physics_multiplayer' )
		self.ChairMDL:SetModel( self.ChairModel )
		self.ChairMDL:SetPos( vecmdl )
		self.ChairMDL:SetAngles( angmdl )
		self.ChairMDL:SetMoveParent( self )
	end
	self.ChairMDL:DrawShadow( false )

	self.ChairMDL:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	if isNewChair then
		self.ChairMDL:Spawn()
		self.ChairMDL:Activate()
	end
	self.ChairMDL:SetOwner( self )

	local phys = self.ChairMDL:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

	self.ChairMDL:SetKeyValue( 'minhealthdmg', '999999' )

	-- Chair Vehicle
	local isNewChair = false
	if not IsValid(self.Chair) or self.Chair:GetOwner() ~= self then
		isNewChair = true
		self.Chair = ents.Create( 'prop_vehicle_prisoner_pod' )
		self.Chair:SetModel( 'models/nova/airboat_seat.mdl' )
		self.Chair:SetPos( vecvehicle )
		self.Chair:SetAngles( angvehicle )
		self.Chair:SetMoveParent( self.ChairMDL )
	end
	self.Chair:SetKeyValue( 'vehiclescript','scripts/vehicles/prisoner_pod.txt' )
	self.Chair:SetNotSolid( true )
	self.Chair:SetNoDraw( true )
	self.Chair:DrawShadow( false )
	self.Chair:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self.Chair.HandleAnimation = HandleRollercoasterAnimation
	self.Chair:SetOwner( self )
	self.Chair.DuckInstrumentChair = true

	if isNewChair then
		self.Chair:Spawn()
		self.Chair:Activate()
	end

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

function ENT:PostEntityPaste( ply, _, entsTable )
	if table.Count(entsTable) <= 1 then return end

	for _, ent in pairs(entsTable) do
		if ent:GetClass() == "prop_physics" then
			ent:Remove()
		end

		if ent:GetClass() == "prop_vehicle_prisoner_pod" then
			ent:Remove()
		end
	end
	self:SetupChair()
end

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
		local songId = net.ReadUInt(7)
		if not ent:CanUseAutoPlay(songId) then return end

		ent.MidiCurrent = songId
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

		-- We don't have any playing Midi
		if not ent.MidiCurrent then return end

		net.Start('DuckInstrumentNetwork')
			net.WriteEntity( ent )
			net.WriteUInt( INSTNET_MIDISTART, 3 )
			net.WriteUInt( ent.MidiCurrent, 7 )
			net.WriteDouble( ent.MidiStartTime )
		net.Send(client)

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
