local IsLocalGame = game.SinglePlayer()

function ENT:MidiInterface()
	if IsValid(self.MidiPanel) or self.MidiCurrent then return end
	if not self:CanUseAutoPlay() then return end

	local frame = vgui.Create('DFrame')
	frame:SetSize(450, ScrH() * 0.9)
	frame:Center()
	frame:SetTitle('#duckInstrument.SongList')
	frame:SetSkin("DeadDuck Instruments")
	frame:SetMinHeight(400)
	frame:SetMinWidth(450)
	frame:SetSizable(true)
	frame:MakePopup()
	self.MidiPanel = frame

	frame.ent = self
	frame.OldThink = frame.Think
	function frame:Think()
		self:OldThink()
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
	searchBar:Dock(FILL)
	searchBar:DockMargin(120, 0, 120, 0)
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
	songList:SetDataHeight(74)
	songList:AddColumn('#duckInstrument.filTitle')
	songList:AddColumn('#duckInstrument.filDuration')
	songList:AddColumn('#duckInstrument.filNotes')
	if IsLocalGame then songList:AddColumn('#duckInstrument.filSource') end
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

	local trDurText = language.GetPhrase("duckInstrument.Duration")
	local trNotesText = language.GetPhrase("duckInstrument.NotesCount")
	local trSrcText = language.GetPhrase("duckInstrument.Source")
	local trSrcLocal = language.GetPhrase("duckInstrument.LocalSong")

	for i = 1, #duckInstruments.songNames do
		if not self:CanUseAutoPlay(i) then continue end

		local name = duckInstruments.songNames[i]
		local dur = duckInstruments.GetSongDuration(i)
		local notes = duckInstruments.GetSongNotesCount(i)
		local source = IsLocalGame and duckInstruments.songSources[i]

		local line = songList:AddLine(name, dur, notes, (source or "!!!!!!local") .. name)
		line.songId = i
		line.search = string.lower(name)
		searchBar.songs[#searchBar.songs + 1] = line

		local pnlText = name .. "\n\n" .. Format(trDurText, string.FormattedTime(dur, "%02i:%02i")) .. "\n" .. Format(trNotesText, notes)
		if IsLocalGame then
			pnlText = pnlText .. "\n" .. Format(trSrcText, (source or trSrcLocal))
		end

		local pnl = line.Columns[1]
		pnl:SetText(pnlText)
		pnl:Dock(FILL)
		pnl:DockMargin(5, 0, 0, 0)

		line.Columns[2]:SetText("")
		line.Columns[3]:SetText("")
		if IsLocalGame then line.Columns[4]:SetText("") end

		local songCoverImg = duckInstruments.GetSongCover(i) or "unknown.png"
		local songCover = line:Add("DImage")
		songCover:SetSize(64, 64)
		songCover:Dock(LEFT)
		songCover:DockMargin(5, 5, 0, 5)
		songCover:SetImage("deadduck/instruments/song_covers/" .. songCoverImg)
	end
	songList:SortByColumn( 1 )
end
