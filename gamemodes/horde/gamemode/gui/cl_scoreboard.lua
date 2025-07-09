if GetConVarNumber("horde_enable_scoreboard") == 0 then return end

local scoreboard = {}

local draw_SimpleText = draw.SimpleText

local draw_RoundedBoxEx = draw.RoundedBoxEx
local draw_RoundedBox = draw.RoundedBox

local player_GetAll = player.GetAll

local server_name = GetHostName()
local map_name = game.GetMap()

local color_black_alpha120 = Color(0,0,0,120)

-- EasyLabel
function HORDE:EasyLabel(parent, text, font, textcolor)
	local ELpanel = vgui.Create("DLabel", parent)
	if font then
		ELpanel:SetFont(font or "DefaultFont")
	end
	ELpanel:SetText(text)
	ELpanel:SizeToContents()
	if textcolor then
		ELpanel:SetTextColor(textcolor)
	end
	ELpanel:SetKeyboardInputEnabled(false)
	ELpanel:SetMouseInputEnabled(false)

	return ELpanel
end

function scoreboard:show()

	local width = ScrW() * 0.6
	local height = ScrH() * 0.65

	local title = vgui.Create("DPanel")
	title:SetSize(width, height)
	title:AlignTop( ScrH() * 0.15 )
	--title:SetPos(ScrW()/2 - 1000 / 2, ScrH()/5 - 50)
	title:CenterHorizontal()
	function title:Paint(w, h)
		draw.RoundedBoxEx(8,0,0,w,h * 0.135, Color(30,30,30,150), true, true, false,false)
		draw_SimpleText("Horde - " .. map_name .. " - " .. HORDE.Difficulty[HORDE.CurrentDifficulty].name, "Title", 10, 12, HORDE.color_crimson_dim, TEXT_ALIGN_LEFT)
		draw_SimpleText(server_name, "Title", width - 10, 12, HORDE.color_crimson_dim, TEXT_ALIGN_RIGHT)
	end

	local header = title:Add("DHeaderPanel")
	header:Dock(TOP)
	header:SetSize(title:GetWide(), 45)
	header:DockMargin(0,50,0,0)

	local board = title:Add("DPanel")
	board:Dock(FILL)
	board:SetSize(width)
	--board:AlignTop( ScrH() * 0.25 )
	board:CenterHorizontal()
	--board:SetPos(ScrW()/2-(1000/2), ScrH()/5)
	function board:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(30,30,30,150))
	end

	local ScrollPanel = board:Add("DScrollPanel")
	ScrollPanel:Dock(FILL)

	local Bar = ScrollPanel:GetVBar()
	local butC = 0

	-- Paint ScrollBar
	function Bar:Paint(w,h)
		draw.RoundedBox(8,  w / 2 - w / 2, butC, w / 2, h - butC * 2, color_black_alpha120 )
	end

	function Bar.btnDown:Paint(w,h)
	end

	function Bar.btnUp:Paint(w,h)
		butC = h
	end

	function Bar.btnGrip:Paint(w,h)
		draw.RoundedBox(8,  w / 2 - w / 2, 0, w / 2, h, color_black)
	end
	local PlayerPanels
	if PlayerPanels == nil then
		PlayerPanels = {}
	end

	local function RemovePlayerPanel(panel)
		if panel:IsValid() then
			PlayerPanels[panel:GetPlayer()] = nil
			panel:Remove()
		end
	end

	for pl, panel in pairs(PlayerPanels) do
		if not panel:IsValid() or pl:IsValid() and pl:IsSpectator() then
			RemovePlayerPanel(panel)
		end
	end

	local function GetPlayerPanel(pl)
		for _, panel in pairs(PlayerPanels) do
			if panel:IsValid() and panel:GetPlayer() == pl then
				return panel
			end
		end
	end

	local function CreatePlayerPanel(pl)
		local curpan = GetPlayerPanel(pl)
		if curpan and curpan:IsValid() then return curpan end

		local panel = ScrollPanel:Add("DPlayerLine")
		panel:SetPlayer(pl)
		panel:Dock(TOP)
		panel:DockMargin(ScrollPanel:GetWide() * 0.01, 2, ScrollPanel:GetWide() * 0.01, 2)

		PlayerPanels[pl] = panel

		return panel
	end

	board:SizeToChildren(true, false)

	local player_score = {}
	for _, ply in pairs(player.GetAll()) do
		player_score[ply] = ply:Frags()
	end

	for ply, _ in SortedPairsByValue(player_score, true) do
		CreatePlayerPanel(ply)
	end

	if outfitter and outfitter.GUIOpen then
		local outfitterButton = vgui.Create( "DButton" )
		scoreboard.OutfitterButton = outfitterButton
		outfitterButton:SetText( "Outfitter" )
		outfitterButton:SetSize( 200, 40 )
		outfitterButton:SetPos( 5, ScrH() / 2 + 25 )
		outfitterButton:SetTextColor( Color( 255, 255, 255 ) )

		function outfitterButton:DoClick()
			outfitter.GUIOpen()
		end

		function outfitterButton:Paint( w, h )
			if self:IsHovered() then
				draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
			else
				draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
			end
		end
	end

	if hook.GetTable().HUDPaint and hook.GetTable().HUDPaint["SimpleTP.HUDPaint"] then
		local thirdPerson = vgui.Create( "DButton" )
		scoreboard.ThirdPerson = thirdPerson
		thirdPerson:SetText( "Third Person" )
		thirdPerson:SetSize( 200, 40 )
		thirdPerson:SetPos( 5, ScrH() / 2 - 25 )
		thirdPerson:SetTextColor( Color( 255, 255, 255 ) )

		function thirdPerson:DoClick()
			-- Weird global from Simple Third Person
			local frame = vgui.Create( "DFrame" )
			BuildMenu( frame )
			frame:SetSize( 300, 200 )
			frame:Center()
			frame:MakePopup()
		end

		function thirdPerson:Paint( w, h )
			if self:IsHovered() then
				draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
			else
				draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
			end
		end
	end
	
	if wardrobe then
		local wardrobeButton = vgui.Create( "DButton" )
		scoreboard.WardrobeButton = wardrobeButton
		wardrobeButton:SetText( "Wardrobe" )
		wardrobeButton:SetSize( 200, 40 )
		wardrobeButton:SetPos( 5, ScrH() / 3 + 25 )
		wardrobeButton:SetTextColor( Color( 255, 255, 255 ) )

		function wardrobeButton:DoClick()
			wardrobe.openMenu()
		end

		function wardrobeButton:Paint( w, h )
			if self:IsHovered() then
				draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
			else
				draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
			end
		end
	end
	
		local keybindButton = vgui.Create( "DButton" )
		scoreboard.KeyBindButton = keybindButton
		keybindButton:SetText( "Key Binds" )
		keybindButton:SetSize( 200, 40 )
		keybindButton:SetPos( 5, ScrH() / 2.2 - 20 )
		keybindButton:SetTextColor( Color( 255, 255, 255 ) )

		function keybindButton:DoClick()
			local frame = vgui.Create( "DFrame" )
			frame:SetSize( 600, 400 )
			frame:SetTitle( "" )
			frame:Center()
			frame:MakePopup()
			frame.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
				draw.RoundedBox( 0, 0, 0, w, h, Color( 231, 76, 60, 255 ) ) -- Draw a red box instead of the frame
				draw.SimpleText("Key Binds UI", "Trebuchet18", 250, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				draw.SimpleText("Right now, If you do the knuckleblast, you can only do both the punch and the blast.", "Trebuchet18", 250, 310, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				draw.SimpleText("Bind +knuckleblast in the console if you want control over this.", "Trebuchet18", 250, 340, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
			
			local number = vgui.Create( "DButton", frame )
			number:SetSize( 250, 90 )
			number:SetPos( 30, 200 )
			number:SetFont( "Trebuchet18" )
			number:SetText( "Numbers correspond to a key in this page" )
			number.DoClick = function()
				gui.OpenURL( "https://wiki.facepunch.com/gmod/Enums/KEY" )
			end
			
			local number2 = vgui.Create( "DButton", frame )
			number2:SetSize( 250, 90 )
			number2:SetPos( 325, 200 )
			number2:SetFont( "Trebuchet18" )
			number2:SetText( "Reset all Keybinds" )
			number2.DoClick = function()
				CKeyBinder.RemoveBind("+feedbacker")
				CKeyBinder.RemoveBind("-feedbacker")
				CKeyBinder.RemoveBind("feedbacker_swap")
				CKeyBinder.RemoveBind("+feedback")
				CKeyBinder.RemoveBind("+knuckleblast")
				CKeyBinder.RemoveBind("-knuckleblast")
				CKeyBinder.RemoveBind("+ultrakill_dash_bind")
				CKeyBinder.RemoveBind("+ultrakill_slam_bind")
				chat.AddText(Color(155, 255, 255), "All binds reset.")
			end
			
			function frame:OnClose()
				number:Remove()
			end
			
			function ComboBoxAdd(command, text, x, y)
				local DComboBox = vgui.Create( "DComboBox", frame )
				DComboBox:SetPos( x, y )
				DComboBox:SetSize( 110, 40 )
				DComboBox:SetFont( "Trebuchet18" )
				DComboBox:SetValue( text )
				for i = 0, 113 do
					DComboBox:AddChoice(i)
				end
				DComboBox.OnSelect = function( self, index, value )
					if CLIENT then
						if value == 0 then 
						LocalPlayer():PrintMessage( HUD_PRINTCENTER, "The key has been unbound." )
						chat.AddText(Color(155, 255, 255), "The key has been unbound.")
						return end
						LocalPlayer():PrintMessage( HUD_PRINTCENTER, input.GetKeyName(value) )
						chat.AddText(Color(155, 255, 255), input.GetKeyName(value))
					end
					CKeyBinder.AddBind(value, command)
				end
			end
			
			function ComboBoxAdd2(command, text, x, y, command2)
				local DComboBox = vgui.Create( "DComboBox", frame )
				DComboBox:SetPos( x, y )
				DComboBox:SetSize( 110, 40 )
				DComboBox:SetFont( "Trebuchet18" )
				DComboBox:SetValue( text )
				for i = 0, 113 do
					DComboBox:AddChoice(i)
				end
				DComboBox.OnSelect = function( self, index, value )
					if CLIENT then
						if value == 0 then 
						LocalPlayer():PrintMessage( HUD_PRINTCENTER, "The key has been unbound." )
						chat.AddText(Color(155, 255, 255), "The key has been unbound.")
						return end
						LocalPlayer():PrintMessage( HUD_PRINTCENTER, input.GetKeyName(value) )
						chat.AddText(Color(155, 255, 255), input.GetKeyName(value))
					end
					CKeyBinder.AddBind(value, command)
					CKeyBinder.AddBind(value, command2)
				end
			end
		
			ComboBoxAdd2("+feedbacker", "Arms Bind", 5, 30, "-feedbacker")
			ComboBoxAdd("feedbacker_swap", "Swap Arms Bind", 125, 30)
			ComboBoxAdd("+feedback", "Individual Feedbacker Bind", 245, 30)
			ComboBoxAdd2("+knuckleblast", "Individual Knuckleblast Bind", 365, 30, "-knuckleblast")
			ComboBoxAdd("+ultrakill_dash_bind", "Dash Bind", 485, 30)
			ComboBoxAdd("+ultrakill_slam_bind", "Groundslam Bind", 5, 90)
			
		end
		
		function keybindButton:OnClose()
			number:Remove()
		end

		function keybindButton:Paint( w, h )
			if self:IsHovered() then
				draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
			else
				draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
			end
		end
		
		/*local logbookButton = vgui.Create( "DButton" )
		scoreboard.LogBookButton = logbookButton
		logbookButton:SetText( "Logbook" )
		logbookButton:SetSize( 200, 40 )
		logbookButton:SetPos( 5, ScrH() / 2 - 20 )
		logbookButton:SetTextColor( Color( 255, 255, 255 ) )
		
		function logbookButton:DoClick()
			local frame = vgui.Create( "DFrame" )
			frame:SetSize( 600, 400 )
			frame:SetTitle( "" )
			frame:Center()
			frame:MakePopup()
			frame.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) ) -- Draw a red box instead of the frame
				draw.SimpleText("Log Book UI", "Trebuchet18", 250, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				draw.SimpleText("This is a summary of the enemies and their weaknesses.", "Trebuchet18", 250, 310, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
			
			local enemytable = {
				"Sprinters and Walkers",
				"Gonomes",
				"Screechers",
				"Exploders",
				"Crawlers",
				"Scragg",
				"Fast Zombies",
				"Poison Zombies",
				"Wraith",
				"Vomitter",
				"Cyst",
				"Healer",
				"Zombine",
				"Traducer",
				"Deterrent",
			}
			
			local number1 = vgui.Create( "DButton", frame )
			number1:SetSize( 250, 90 )
			number1:SetPos( 325, 200 )
			number1:SetFont( "Trebuchet18" )
			number1:SetText( "Sprinters and Walkers" )
			for k, ent in pairs(enemytable) do
				DComboBox:AddChoice(ent)
			end
			number1.DoClick = function()
			end
			
			function frame:OnClose()
				number1:Remove()
			end
			
		end
		
		function logbookButton:OnClose()
			number:Remove()
		end

		function logbookButton:Paint( w, h )
			if self:IsHovered() then
				draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
			else
				draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
			end
		end*/

	function scoreboard:hide()
		-- This is where you hide the scoreboard, such as with Base:Remove()`
		for _, panel in pairs( PlayerPanels ) do
			if panel.SubMenu then
				panel.SubMenu:Remove()
			end
		end
		gui.EnableScreenClicker(false)
		board:Remove()
		title:Remove()
		if IsValid(self.ThirdPerson) then
			self.ThirdPerson:Remove()
		end

		if IsValid(self.OutfitterButton) then
			self.OutfitterButton:Remove()
		end
		
		if IsValid(self.WardrobeButton) then
			self.WardrobeButton:Remove()
		end
		
		if IsValid(self.KeyBindButton) then
			self.KeyBindButton:Remove()
		end
		hook.Remove("KeyPress", "Horde_Scoreboard_Mouse")
	end

	hook.Add("KeyPress", "Horde_Scoreboard_Mouse", function(ply, key)
		if board and title and (key == IN_ATTACK or key == IN_ATTACK2 or key == IN_USE) then
			gui.EnableScreenClicker(true)
		end
	end)
end

function GM:ScoreboardShow()
	scoreboard:show()
end

function GM:ScoreboardHide()
    if not scoreboard then return end
	scoreboard:hide()
end