
local surface = surface
local Color = Color

SKIN = {}

SKIN.PrintName		= "DeadDuck Instruments"
SKIN.Author			= "DeadDuck"
SKIN.DermaVersion	= 1
SKIN.GwenTexture	= Material( "gwenskin/GModDefault.png" )

SKIN.colTextEntryBG				= Color( 20, 20, 20, 255 )
SKIN.colTextEntryBorder			= Color( 60, 60, 60, 255 )
SKIN.colTextEntryText			= Color( 235, 235, 235, 255 )
SKIN.colTextEntryTextHighlight	= Color( 20, 240, 250, 255 )
SKIN.colTextEntryTextCursor		= Color( 255, 255, 255, 255 )
SKIN.colTextEntryTextPlaceholder= Color( 138, 138, 138, 255 )

SKIN.Colours = {}

SKIN.Colours.Window = {}
SKIN.Colours.Window.TitleActive		= GWEN.TextureColor( 4 + 8 * 0, 508 )
SKIN.Colours.Window.TitleInactive	= GWEN.TextureColor( 4 + 8 * 1, 508 )

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal		= Color( 220, 220, 220, 255 )
SKIN.Colours.Button.Disabled	= Color( 128, 128, 128, 255 )
SKIN.Colours.Button.Down		= Color( 200, 200, 200, 255 )
SKIN.Colours.Button.Hover		= Color( 210, 210, 210, 255 )

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Active = {}
SKIN.Colours.Tab.Active.Normal		= GWEN.TextureColor( 4 + 8 * 4, 508 )
SKIN.Colours.Tab.Active.Hover		= GWEN.TextureColor( 4 + 8 * 5, 508 )
SKIN.Colours.Tab.Active.Down		= GWEN.TextureColor( 4 + 8 * 4, 500 )
SKIN.Colours.Tab.Active.Disabled	= GWEN.TextureColor( 4 + 8 * 5, 500 )

SKIN.Colours.Tab.Inactive = {}
SKIN.Colours.Tab.Inactive.Normal	= GWEN.TextureColor( 4 + 8 * 6, 508 )
SKIN.Colours.Tab.Inactive.Hover		= GWEN.TextureColor( 4 + 8 * 7, 508 )
SKIN.Colours.Tab.Inactive.Down		= GWEN.TextureColor( 4 + 8 * 6, 500 )
SKIN.Colours.Tab.Inactive.Disabled	= GWEN.TextureColor( 4 + 8 * 7, 500 )

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default			= GWEN.TextureColor( 4 + 8 * 8, 508 )
SKIN.Colours.Label.Bright			= GWEN.TextureColor( 4 + 8 * 9, 508 )
SKIN.Colours.Label.Dark				= Color(255, 255, 255, 255)
SKIN.Colours.Label.Highlight		= GWEN.TextureColor( 4 + 8 * 9, 500 )

SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines				= GWEN.TextureColor( 4 + 8 * 10, 508 ) ---- !!!
SKIN.Colours.Tree.Normal			= GWEN.TextureColor( 4 + 8 * 11, 508 )
SKIN.Colours.Tree.Hover				= GWEN.TextureColor( 4 + 8 * 10, 500 )
SKIN.Colours.Tree.Selected			= GWEN.TextureColor( 4 + 8 * 11, 500 )

SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Line_Normal			= GWEN.TextureColor( 4 + 8 * 12, 508 )
SKIN.Colours.Properties.Line_Selected		= GWEN.TextureColor( 4 + 8 * 13, 508 )
SKIN.Colours.Properties.Line_Hover			= GWEN.TextureColor( 4 + 8 * 12, 500 )
SKIN.Colours.Properties.Title				= GWEN.TextureColor( 4 + 8 * 13, 500 )
SKIN.Colours.Properties.Column_Normal		= GWEN.TextureColor( 4 + 8 * 14, 508 )
SKIN.Colours.Properties.Column_Selected		= GWEN.TextureColor( 4 + 8 * 15, 508 )
SKIN.Colours.Properties.Column_Hover		= GWEN.TextureColor( 4 + 8 * 14, 500 )
SKIN.Colours.Properties.Column_Disabled		= Color( 240, 240, 240 )
SKIN.Colours.Properties.Border				= GWEN.TextureColor( 4 + 8 * 15, 500 )
SKIN.Colours.Properties.Label_Normal		= GWEN.TextureColor( 4 + 8 * 16, 508 )
SKIN.Colours.Properties.Label_Selected		= GWEN.TextureColor( 4 + 8 * 17, 508 )
SKIN.Colours.Properties.Label_Hover			= GWEN.TextureColor( 4 + 8 * 16, 500 )
SKIN.Colours.Properties.Label_Disabled		= GWEN.TextureColor( 4 + 8 * 16, 508 )

SKIN.Colours.Category = {}
SKIN.Colours.Category.Header				= GWEN.TextureColor( 4 + 8 * 18, 500 )
SKIN.Colours.Category.Header_Closed			= GWEN.TextureColor( 4 + 8 * 19, 500 )
SKIN.Colours.Category.Line = {}
SKIN.Colours.Category.Line.Text				= GWEN.TextureColor( 4 + 8 * 20, 508 )
SKIN.Colours.Category.Line.Text_Hover		= GWEN.TextureColor( 4 + 8 * 21, 508 )
SKIN.Colours.Category.Line.Text_Selected	= GWEN.TextureColor( 4 + 8 * 20, 500 )
SKIN.Colours.Category.Line.Text_Disabled	= GWEN.TextureColor( 4 + 8 * 16, 508 )
SKIN.Colours.Category.Line.Button			= GWEN.TextureColor( 4 + 8 * 21, 500 )
SKIN.Colours.Category.Line.Button_Hover		= GWEN.TextureColor( 4 + 8 * 22, 508 )
SKIN.Colours.Category.Line.Button_Selected	= GWEN.TextureColor( 4 + 8 * 23, 508 )
SKIN.Colours.Category.Line.Button_Disabled	= Color( 210, 210, 210 )
SKIN.Colours.Category.LineAlt = {}
SKIN.Colours.Category.LineAlt.Text				= GWEN.TextureColor( 4 + 8 * 22, 500 )
SKIN.Colours.Category.LineAlt.Text_Hover		= GWEN.TextureColor( 4 + 8 * 23, 500 )
SKIN.Colours.Category.LineAlt.Text_Selected		= GWEN.TextureColor( 4 + 8 * 24, 508 )
SKIN.Colours.Category.LineAlt.Text_Disabled		= GWEN.TextureColor( 4 + 8 * 16, 508 )
SKIN.Colours.Category.LineAlt.Button			= GWEN.TextureColor( 4 + 8 * 25, 508 )
SKIN.Colours.Category.LineAlt.Button_Hover		= GWEN.TextureColor( 4 + 8 * 24, 500 )
SKIN.Colours.Category.LineAlt.Button_Selected	= GWEN.TextureColor( 4 + 8 * 25, 500 )
SKIN.Colours.Category.LineAlt.Button_Disabled	= Color( 200, 200, 200 )

SKIN.Colours.TooltipText = GWEN.TextureColor( 4 + 8 * 26, 500 )

function SKIN:PaintFrame(panel, w, h)
	surface.SetDrawColor(23,23,23,196)
	surface.DrawRect(0, 0, w, h)
	surface.DrawRect(0, 0, w, 24)
end

function SKIN:PaintButton( panel, w, h )
	if not panel.m_bBackground then return end

	if panel.Depressed or panel:IsSelected() or panel:GetToggle() then
		surface.SetDrawColor(44,54,54,255)
	elseif panel.Hovered then
		surface.SetDrawColor(74,84,90,255)
	else
		surface.SetDrawColor(64,64,64,255)
	end

	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(100,100,100,255)
	surface.DrawRect(0, 0, 1, h)
	surface.DrawRect(w-1, 0, 1, h)
end

function SKIN:PaintTextEntry( panel, w, h )
	if ( panel.m_bBackground ) then

		surface.SetDrawColor(128,128,128,255)
		surface.DrawRect(0, 0, w, h)

		if ( panel:HasFocus() ) then
			surface.SetDrawColor(74,84,90,255)
		else
			surface.SetDrawColor(40,40,40,255)
		end
		surface.DrawRect(1, 1, w-2, h-2)

	end

	-- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
	if ( panel.GetPlaceholderText && panel.GetPlaceholderColor && panel:GetPlaceholderText() && panel:GetPlaceholderText():Trim() != "" && panel:GetPlaceholderColor() && ( !panel:GetText() || panel:GetText() == "" ) ) then

		local oldText = panel:GetText()

		local str = panel:GetPlaceholderText()
		if ( str:StartsWith( "#" ) ) then str = str:sub( 2 ) end
		str = language.GetPhrase( str )

		panel:SetText( str )
		panel:DrawTextEntryText( panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
		panel:SetText( oldText )

		return
	end

	panel:DrawTextEntryText( panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
end

function SKIN:PaintListView(panel, w, h)
end

function SKIN:PaintListViewLine( panel, w, h )

	if panel:IsSelected() then
		surface.SetDrawColor(0,0,0,196)
	elseif panel.Hovered then
		surface.SetDrawColor(74,84,90,196)
	elseif panel.m_bAlt then
		surface.SetDrawColor(10,10,10,196)
	else
		surface.SetDrawColor(20,20,20,196)
	end
	surface.DrawRect(0, 0, w, h)

end

function SKIN:PaintVScrollBar( panel, w, h )

	surface.SetDrawColor(70,70,70,196)
	surface.DrawRect(0, 0, w, h)

end

derma.DefineSkin("DeadDuck Instruments", "Styled song selector, yeah", SKIN)
