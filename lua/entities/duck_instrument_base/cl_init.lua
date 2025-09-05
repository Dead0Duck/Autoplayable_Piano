include("shared.lua")
include("cl_midi_hud.lua")

list.Set("ContentCategoryIcons", language.GetPhrase("#duckInstrument.Category"), "icon16/music.png")
cvars.AddChangeCallback("gmod_language", function(_, oldV, newV)
	list.Set("ContentCategoryIcons", oldV, nil)
	list.Set("ContentCategoryIcons", newV, "icon16/music.png")
end, "duckInstruments.ent.category")

ENT.DEBUG = true

ENT.MidiCurrentNote = 1
ENT.NoteKeys = {}
ENT.KeysDown = {}
ENT.MidiKeysDown = {}
ENT.KeysWasDown = {}

ENT.ShiftMode = false

ENT.PageTurnSound = Sound( 'gmodtower/inventory/move_paper.wav' )
surface.CreateFont( 'DuckInstrumentKeyLabel', {
	size = 20, weight = 400, antialias = true, font = 'Times New Roman', extended = true
} )
surface.CreateFont( 'DuckInstrumentNotice', {
	size = 36, weight = 400, antialias = true, font = 'Times New Roman', extended = true
} )

-- For drawing purposes
-- Override by adding MatWidth/MatHeight to key data
ENT.DefaultMatWidth = 128
ENT.DefaultMatHeight = 128
-- Override by adding TextX/TextY to key data
ENT.DefaultTextX = 5
ENT.DefaultTextY = 10
ENT.DefaultTextColor = Color( 150, 150, 150, 255 )
ENT.DefaultTextColorActive = Color( 80, 80, 80, 255 )
ENT.DefaultTextInfoColor = Color( 120, 120, 120, 150 )
ENT.MidiProgressBarColor = Color( 255, 0, 0, 50 )

ENT.MaterialDir	= ''
ENT.KeyMaterials = {}

ENT.AdvMainHUD = {
	Material = nil,
	X = 0,
	Y = 0,
	TextureWidth = 128,
	TextureHeight = 128,
	Width = 128,
	Height = 128,
}

ENT.BrowserHUD = {
	URL = 'https://anthfgreco.github.io/playable-piano-v2',
	Show = true, -- display the sheet music?
	X = 0,
	Y = 0,
	Width = 1024,
	Height = 768,
}

function ENT:MidiNotePlay(note)
	local isMePlaying = LocalPlayer().duckInstrument == self
	local timePassed = CurTime() - self.MidiStartTime

	local noteName = self.MidiCurrent[note * 2 - 1]
	if not noteName then
		self.MidiCurrent = nil
		return false
	end

	local noteTime = self.MidiCurrent[note * 2]
	if timePassed < noteTime then return false end

	self.MidiCurrentNote = note + 1

	if timePassed - noteTime > 0.2 then return true end

	local key = self.NoteKeys[noteName]

	if not isMePlaying then
		local sound = self:GetSound(noteName)
		if sound then
			self:EmitSound(sound, 80)
		end

		if key then
			self:NoteEffect(noteName)
		end
		return true
	end

	self:OnRegisteredKeyPlayed(noteName, true)

	if not key then return true end

	self.MidiKeysDown[noteName] = true
	timer.Create( 'duck_inst_note' .. noteName, 0.04, 1, function()
		if not IsValid(self) then return end

		self.MidiKeysDown[noteName] = nil
	end)

	self:NoteEffect(noteName)

	return true
end

function ENT:Initialize()

	for key, keyData in pairs( self.Keys ) do
		self.NoteKeys[keyData.Sound] = key
		if keyData.Shift then self.NoteKeys[keyData.Shift.Sound] = key end
	end

	net.Start( 'DuckInstrumentNetwork' )

		net.WriteEntity( self )
		net.WriteUInt( INSTNET_MIDISPAWN, 3 )

	net.SendToServer()

	self._midPBcolR, self._midPBcolG, self._midPBcolB, self._midPBcolA = self.MidiProgressBarColor:Unpack()

	self:PrecacheMaterials()
end

function ENT:UpdMidi()
	if not self.MidiCurrent then return end

	while self:MidiNotePlay(self.MidiCurrentNote) do
	end
end

local autoPlayKeys = {
	[KEY_TAB] = true,
	[KEY_LCONTROL] = true,
	[KEY_RCONTROL] = true,
}
function ENT:Think()

	if not IsValid( LocalPlayer().duckInstrument ) or LocalPlayer().duckInstrument ~= self then
		self:UpdMidi()
		return
	end

	if not self.MidiCurrent and self.DelayKey and self.DelayKey > CurTime() then return end

	-- Update last pressed
	for keylast, keyData in pairs( self.KeysDown ) do
		self.KeysWasDown[ keylast ] = self.KeysDown[ keylast ]
	end

	-- Get control keys
	for key, keyData in pairs( self.ControlKeys ) do
		if vgui.GetKeyboardFocus() then continue end
		if gui.IsGameUIVisible() then continue end
		if self.MidiCurrent and not autoPlayKeys[key] then continue end

		-- Update key status
		self.KeysDown[ key ] = input.IsKeyDown( key )

		-- Check for control keys
		if self:IsKeyTriggered( key ) then
			keyData( self, true )
		end

		-- was a control key released?
		if self:IsKeyReleased( key ) then
			keyData( self, false )
		end

	end

	if self.MidiCurrent then
		self:UpdMidi()
		return
	end

	if vgui.GetKeyboardFocus() then return end
	-- Get keys
	for key, keyData in pairs( self.Keys ) do

		-- Update key status
		self.KeysDown[ key ] = input.IsKeyDown( key )

		-- Check for note keys
		if self:IsKeyTriggered( key ) then

			if self.ShiftMode and keyData.Shift then
				self:OnRegisteredKeyPlayed( keyData.Shift.Sound )
			elseif not self.ShiftMode then
				self:OnRegisteredKeyPlayed( keyData.Sound )
			end

		end

	end

	-- Send da keys to everyone
	--self:SendKeys()

end

function ENT:IsKeyTriggered( key )
	return self.KeysDown[ key ] and not self.KeysWasDown[ key ]
end

function ENT:IsKeyReleased( key )
	return self.KeysWasDown[ key ] and not self.KeysDown[ key ]
end

function ENT:OnRegisteredKeyPlayed( key, dontNetwork )

	-- Play on the client first
	local sound = self:GetSound( key )
	if sound then
		self:EmitSound( sound, 100 )
	end

	-- Network it
	if dontNetwork then return end
	net.Start( 'DuckInstrumentNetwork' )

		net.WriteEntity( self )
		net.WriteUInt( INSTNET_PLAY, 3 )
		net.WriteString( key )

	net.SendToServer()

	-- Add the notes (limit to max notes)
	--[[ if #self.KeysToSend < self.MaxKeys then

		if not table.HasValue( self.KeysToSend, key ) then -- only different notes, please
			table.insert( self.KeysToSend, key )
		end

	end ]]

end

-- Network it up, yo
function ENT:SendKeys()

	if not self.KeysToSend then return end

	-- Send the queue of notes to everyone

	-- Play on the client first
	for _, key in ipairs( self.KeysToSend ) do

		local sound = self:GetSound( key )

		if sound then
			self:EmitSound( sound, 100 )
		end

	end

	-- Clear queue
	self.KeysToSend = nil

end

function ENT:DrawKey( mainX, mainY, key, keyData, bShiftMode )

	local isDown = self.MidiCurrent and self.MidiKeysDown[keyData.Sound]
		or (self.ShiftMode and bShiftMode and input.IsKeyDown(key)) 
		or (not self.ShiftMode and not bShiftMode and input.IsKeyDown( key ))

	if keyData.Material and isDown then
		surface.SetTexture( self.KeyMaterialIDs[ keyData.Material ] )
		surface.DrawTexturedRect( mainX + keyData.X, mainY + keyData.Y, self.DefaultMatWidth, self.DefaultMatHeight )
	end

	if not keyData.Label then return end
	if self.MidiCurrent then return end

	local offsetX = self.DefaultTextX
	local offsetY = self.DefaultTextY
	local color = self.DefaultTextColor

	if isDown then
		color = self.DefaultTextColorActive
		if keyData.AColor then color = keyData.AColor end
	else
		if keyData.Color then color = keyData.Color end
	end

	if keyData.TextX then offsetX = keyData.TextX end
	if keyData.TextY then offsetY = keyData.TextY end

	draw.DrawText( keyData.Label, 'DuckInstrumentKeyLabel',
		mainX + keyData.X + offsetX,
		mainY + keyData.Y + offsetY,
		color, TEXT_ALIGN_CENTER )
end

function ENT:DrawHUD()

	surface.SetDrawColor( 255, 255, 255, 255 )

	local mainX, mainY, mainWidth, mainHeight

	-- Advanced main
	if self.AdvMainHUD.Material then

		mainX, mainY, mainWidth, mainHeight = self.AdvMainHUD.X, self.AdvMainHUD.Y, self.AdvMainHUD.Width, self.AdvMainHUD.Height

		surface.SetTexture( self.AdvMainHUD.MatID )
		surface.DrawTexturedRect( mainX, mainY, self.AdvMainHUD.TextureWidth, self.AdvMainHUD.TextureHeight )

	end

	-- Draw keys (over top of main)
	for key, keyData in pairs( self.Keys ) do

		self:DrawKey( mainX, mainY, key, keyData, false )

		if keyData.Shift then
			self:DrawKey( mainX, mainY, key, keyData.Shift, true )
		end
	end

	-- Sheet music help
	if not self.MidiCurrent and not IsValid( self.Browser ) and self.BrowserHUD.Show then

		draw.DrawText( '#duckInstrument.Space', 'DuckInstrumentKeyLabel',
						mainX + ( mainWidth / 2 ), mainY + 60,
						self.DefaultTextInfoColor, TEXT_ALIGN_CENTER )

	end

	-- Midi Info
	if self.MidiCurrent then
		self:DrawHUDMidi()
	end

end

function ENT:PrecacheMaterials()

	if not self.Keys then return end

	self.KeyMaterialIDs = {}

	for name, keyMaterial in pairs( self.KeyMaterials ) do
		if type( keyMaterial ) == 'string' then
			self.KeyMaterialIDs[name] = surface.GetTextureID( keyMaterial )
		end
	end

	if self.AdvMainHUD.Material then
		self.AdvMainHUD.MatID = surface.GetTextureID( self.AdvMainHUD.Material )
	end

end

function ENT:OpenSheetMusic()

	if IsValid( self.Browser ) or not self.BrowserHUD.Show then return end

	self.Browser = vgui.Create( 'HTML' )
	self.Browser:SetVisible( false )

	local width = self.BrowserHUD.Width

	if self.BrowserHUD.AdvWidth then
		width = self.BrowserHUD.AdvWidth
	end

	local url = self.BrowserHUD.URL

	local x = self.BrowserHUD.X - ( width / 2 )

	self.Browser:OpenURL( url )

	self.Browser:SetVisible( true )
	self.Browser:SetPos( x, self.BrowserHUD.Y )
	self.Browser:SetSize( width, self.BrowserHUD.Height )

end

function ENT:CloseSheetMusic()

	if not IsValid( self.Browser ) then return end

	self.Browser:Remove()
	self.Browser = nil

end

function ENT:ToggleSheetMusic()

	if IsValid( self.Browser ) then
		self:CloseSheetMusic()
	else
		self:OpenSheetMusic()
	end

end

function ENT:SheetMusicForward()

	if not IsValid( self.Browser ) then return end

	self.Browser:Exec( 'pageForward()' )
	self:EmitSound( self.PageTurnSound, 100, math.random( 120, 150 ) )

end

function ENT:SheetMusicBack()

	if not IsValid( self.Browser ) then return end

	self.Browser:Exec( 'pageBack()' )
	self:EmitSound( self.PageTurnSound, 100, math.random( 100, 120 ) )

end

function ENT:OnRemove()

	self:CloseSheetMusic()

end

function ENT:Shutdown()

	self.MidiCurrent = nil
	self.MidiStartTime = nil
	self.MidiCurrentNote = 1

	self:CloseSheetMusic()

	self.ShiftMode = false

	--[[
	if self.OldKeys then
		self.Keys = self.OldKeys
		self.OldKeys = nil
	end
	--]]
end

function ENT:ToggleShiftMode()
	self.ShiftMode = not self.ShiftMode
end

function ENT:CtrlMod( bPressed )
	permissions.EnableVoiceChat( bPressed )
end

function ENT:ShiftMod()
	self:ToggleShiftMode()
end

hook.Add( 'HUDPaint', 'DuckInstrumentPaint', function()

	local inst = LocalPlayer().duckInstrument
	if IsValid( inst ) then

		inst:DrawHUD()

		surface.SetDrawColor( 0, 0, 0, 180 )
		surface.DrawRect( 0, ScrH() - 60, ScrW(), 60 )

		if inst.MidiCurrent then
			draw.SimpleText( '#duckInstrument.Tab1', 'DuckInstrumentNotice', ScrW() / 2, ScrH() - 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
		elseif inst:CanUseAutoPlay() then
			draw.SimpleText( '#duckInstrument.Tab2', 'DuckInstrumentNotice', ScrW() / 2, ScrH() - 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
		else
			draw.SimpleText( '#duckInstrument.Tab2_NoAutoplay', 'DuckInstrumentNotice', ScrW() / 2, ScrH() - 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
		end

	end

end )

-- Override regular keys
hook.Add( 'PlayerBindPress', 'DuckInstrumentHook', function( ply, bind, pressed )

	if IsValid( ply.duckInstrument ) then
		return true
	end

end )

net.Receive( 'DuckInstrumentNetwork', function( length, client )

	local ent = net.ReadEntity()
	local enum = net.ReadUInt( 3 )

	-- When the player uses it or leaves it
	if enum == INSTNET_USE then

		if IsValid( LocalPlayer().duckInstrument ) then
			LocalPlayer().duckInstrument:Shutdown()
		end

		ent.DelayKey = CurTime() + .1 -- delay to the key a bit so they don't play on use key
		LocalPlayer().duckInstrument = ent

	-- Play the notes for everyone else
	elseif enum == INSTNET_HEAR then

		-- Instrument doesn't exist
		if not IsValid( ent ) then return end

		-- Don't play for the owner, they've already heard it!
		if IsValid( LocalPlayer().duckInstrument ) and LocalPlayer().duckInstrument == ent then
			return
		end

		-- Gather note
		local key = net.ReadString()
		local sound = ent:GetSound( key )

		if sound then
			ent:EmitSound( sound, 80 )
		end

		-- Gather notes
		--[[ local keys = net.ReadTable()
	
		for i=1, #keys do

			local key = keys[1]
			local sound = ent:GetSound( key )
			
			if sound then
				ent:EmitSound( sound, 80 )

				local eff = EffectData()
				eff:SetOrigin( ent:GetPos() + Vector(0, 0, 60) )
				eff:SetEntity( ent )

				util.Effect( 'musicnotes', eff, true, true )
			end
			
		end ]]

	-- Start playing auto-piano
	elseif enum == INSTNET_MIDISTART then

		if not IsValid(ent) then return end

		local myInst = LocalPlayer().duckInstrument
		if myInst == ent then
			return
		end

		local index = net.ReadUInt(7)
		if not duckInstruments.songs[index] then return end

		ent.MidiCurrent = duckInstruments.songs[index]
		ent.MidiCurrentId = index
		ent.MidiStartTime = net.ReadDouble()
		ent.MidiCurrentNote = 1

	-- Stop playing auto-piano
	elseif enum == INSTNET_MIDISTOP then

		if not IsValid( ent ) then return end

		ent.MidiCurrent = nil
		ent.MidiStartTime = nil
		ent.MidiCurrentNote = 1

	end

end )


function ENT:MidiInterface()
	if IsValid(self.MidiPanel) or self.MidiCurrent then return end
	if not self:CanUseAutoPlay() then return end

	local frame = vgui.Create('DFrame')
	frame:SetSize(450,400)
	frame:Center()
	frame:SetTitle('#duckInstrument.SongList')
	frame:SetDraggable(true)
	frame:ShowCloseButton(true)
	frame:MakePopup()
	self.MidiPanel = frame

	frame.ent = self
	function frame:Think()
		if not IsValid(self.ent) or LocalPlayer().duckInstrument ~= self.ent then
			self:Remove()
		end
	end

	local topBar = frame:Add('DPanel')
	topBar:SetPaintBackground(false)
	topBar:Dock(TOP)
	topBar:DockMargin(0, 0, 0, 5)

	local songList

	local searchBar = topBar:Add("DTextEntry")
	searchBar:Dock(RIGHT)
	searchBar:DockMargin(0, 0, 120, 0)
	searchBar:SetWide(200)
	searchBar:SetPlaceholderText("#spawnmenu.search")
	searchBar:SetUpdateOnType(true)
	searchBar.songs = {}

	searchBar.OnValueChange = function(self, v)
		local isEmpty = (v == "")
		v = string.lower(v)

		for i = 1, #self.songs do
			local pnl = self.songs[i]
			if isEmpty or string.find(pnl.search or "", v, 1, true) then
				pnl:Show()
			else
				pnl:Hide()
			end
		end

		songList:SetDirty(true)
		songList:InvalidateLayout()
	end
	searchBar:RequestFocus()


	songList = vgui.Create('DListView', frame)
	songList:SetMultiSelect(false)
	songList:Dock(FILL)
	songList:AddColumn('#duckInstrument.Songs')
	songList.OnRowSelected = function(lst, _, pnl)
		if not IsValid( self ) then
			frame:Close()
			return
		end

		local inst = LocalPlayer().duckInstrument
		if not IsValid(inst) or inst ~= self then
			frame:Close()
			return
		end

		local songId = pnl.songId
		if not self:CanUseAutoPlay(songId) then
			frame:Close()
			return
		end

		self:CloseSheetMusic()

		self.MidiName = duckInstruments.songNames[songId]
		self.MidiCurrent = duckInstruments.songs[songId]
		self.MidiCurrentId = songId
		self.MidiStartTime = CurTime()
		self.MidiCurrentNote = 1
		self.MidiKeysDown = {}

		net.Start('DuckInstrumentNetwork')
			net.WriteEntity( self )
			net.WriteUInt( INSTNET_MIDISTART, 3 )
			net.WriteUInt( songId, 7 )
		net.SendToServer()

		frame:Close()
	end

	for i = 1, #duckInstruments.songNames do
		if not self:CanUseAutoPlay(i) then continue end
		local pnl = songList:AddLine(duckInstruments.songNames[i])
		pnl.songId = i
		pnl.search = string.lower(duckInstruments.songNames[i])
		searchBar.songs[#searchBar.songs + 1] = pnl
	end
	songList:SortByColumn( 1 )
end
