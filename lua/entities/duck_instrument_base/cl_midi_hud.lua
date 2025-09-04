local surface_GetTextureID = surface.GetTextureID
local Color = Color
local ScrH = ScrH
local draw_TexturedQuad = draw.TexturedQuad
local Format = Format
local language_GetPhrase = language.GetPhrase
local draw_TextShadow = draw.TextShadow
local CurTime = CurTime
local math_min = math.min
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawRect = surface.DrawRect
local surface_DrawTexturedRect = surface.DrawTexturedRect
local string_FormattedTime = string.FormattedTime

local hudHeight = 0
local hudGradient = surface_GetTextureID( "gui/gradient" )
local hudColor = Color( 10, 10, 10, 180 )
local hudColor2 = Color( 10, 10, 10, 230 )

local TextTable = {
	font = "DuckInstrumentKeyLabel",
	color = Color( 240, 240, 240, 255 ),
}
local QuadTable = {
	texture = hudGradient,
	color = hudColor,
}

local songCoversCache = {}
function ENT:DrawHUDMidi()
	local x, y = 20, self.AdvMainHUD.Y - 40
	local w, h = 0, 0

	QuadTable.x = 0
	QuadTable.y = y - 8
	QuadTable.w = 800
	QuadTable.h = hudHeight - ( y - 8 )
	QuadTable.color = hudColor
	draw_TexturedQuad( QuadTable )

	local songCover = duckInstruments.songCovers[self.MidiCurrentId]
	if songCover then
		songCoversCache[songCover] = songCoversCache[songCover] or Material("deadduck/instruments/song_covers/" .. songCover, "smooth")
		songCover = songCoversCache[songCover]

		surface_SetDrawColor(255,255,255,255)
		surface_SetMaterial(songCover)
		surface_DrawTexturedRect(x, y + 2, 56, 56)
		x = x + 10 + 56
	end

	TextTable.pos = { x, y }
	TextTable.xalign = TEXT_ALIGN_LEFT
	TextTable.text = Format( language_GetPhrase("duckInstrument.AutoPlaying"), self.MidiName or "???" )
	w, h = draw_TextShadow( TextTable, 2 )
	y = y + h + 8

	local maxTime = self.MidiCurrent[#self.MidiCurrent]
	local curTime = CurTime() - self.MidiStartTime

	local maxWidth = 450
	local curWidth = math_min((curTime / maxTime) * maxWidth, maxWidth)

	surface_SetDrawColor(0,0,0,196)
	surface_DrawRect(x, y, maxWidth, 30)

	surface_SetDrawColor(self._midPBcolR, self._midPBcolG, self._midPBcolB, self._midPBcolA)
	surface_DrawRect(x, y, curWidth, 30)

	TextTable.pos = { x + 5, y + 5 }
	TextTable.text = string_FormattedTime(curTime, "%02i:%02i")
	w, h = draw_TextShadow( TextTable, 1 )

	TextTable.pos = { x + 445, y + 5 }
	TextTable.text = string_FormattedTime(maxTime, "%02i:%02i")
	TextTable.xalign = TEXT_ALIGN_RIGHT
	w, h = draw_TextShadow( TextTable, 1 )

	y = y + h + 24
	hudHeight = y

	QuadTable.y = y
	QuadTable.h = 0
	QuadTable.color = hudColor2
	draw_TexturedQuad( QuadTable )

	y = y + 4
end