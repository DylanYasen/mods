local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"
local Spinner = require "widgets/spinner"

local GeometricOptionsScreen = Class(Screen, function(self)
	Screen._ctor(self, "GeometricOptionsScreen")

	self.active = true
	SetPause(true,"pause")
	
	self.togglekey = "B"
	self.togglekey = self.togglekey:lower():byte()
	
	-- make it so that all callbacks are an empty function by default
	-- the modmain will set up the callbacks to manipulate modmain options
	local blank_function = function() end
	local blank_function_table = {__index = function() return blank_function end}
	self.callbacks = {}
	setmetatable(self.callbacks, blank_function_table)
	
	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.5)	

	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
	self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(284, 288, 0.75, 0.75, 50, -31))
    self.bg:SetPosition(-5,0)
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
	self.bg.fill:SetSize(619, 359) -- defaults to 619, 359
	self.bg.fill:SetPosition(2, 10)
	
	--title	
    self.title = self.proot:AddChild(Text(BUTTONFONT, 50))
    self.title:SetPosition(0, 135, 0)
    self.title:SetString("Geometric Placement Options")
    self.title:SetColour(0,0,0,1)

	--subtitles
    self.subtitle_geometry = self.proot:AddChild(Text(NEWFONT_SMALL, 25))
    self.subtitle_geometry:SetPosition(-205, 75, 0)
    self.subtitle_geometry:SetString("Geometry")
    self.subtitle_geometry:SetColour(0,0,0,1)
	
    self.subtitle_geometry1 = self.proot:AddChild(Text(NEWFONT_SMALL, 18))
    self.subtitle_geometry1:SetPosition(-250, 40, 0)
    self.subtitle_geometry1:SetString("Axis\nAligned")
    self.subtitle_geometry1:SetColour(0,0,0,1)
	
    self.subtitle_geometry2 = self.proot:AddChild(Text(NEWFONT_SMALL, 18))
    self.subtitle_geometry2:SetPosition(-160, 40, 0)
    self.subtitle_geometry2:SetString("Default\nCamera")
    self.subtitle_geometry2:SetColour(0,0,0,1)
	
	self.vertical_line1 = self.proot:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
	self.vertical_line1:SetScale(.7, .38)
	self.vertical_line1:SetPosition(-100, -40)

    self.subtitle_color = self.proot:AddChild(Text(NEWFONT_SMALL, 25))
    self.subtitle_color:SetPosition(0, 75, 0)
    self.subtitle_color:SetString("Colors")
    self.subtitle_color:SetColour(0,0,0,1)

	self.vertical_line2 = self.proot:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
	self.vertical_line2:SetScale(.7, .38)
	self.vertical_line2:SetPosition(100, -40)

    self.subtitle_misc = self.proot:AddChild(Text(NEWFONT_SMALL, 25))
    self.subtitle_misc:SetPosition(205, 75, 0)
    self.subtitle_misc:SetString("Other")
    self.subtitle_misc:SetColour(0,0,0,1)

    self.subtitle_refresh = self.proot:AddChild(Text(NEWFONT_SMALL, 22))
    self.subtitle_refresh:SetPosition(160, -30, 0)
    self.subtitle_refresh:SetString("Refresh Speed:")
    self.subtitle_refresh:SetColour(0,0,0,1)

    self.subtitle_gridsize = self.proot:AddChild(Text(NEWFONT_SMALL, 22))
    self.subtitle_gridsize:SetPosition(205, -80, 0)
    self.subtitle_gridsize:SetString("Grid Sizes")
    self.subtitle_gridsize:SetColour(0,0,0,1)

    self.subtitle_gridsize1 = self.proot:AddChild(Text(NEWFONT_SMALL, 18))
    self.subtitle_gridsize1:SetPosition(125, -100, 0)
    self.subtitle_gridsize1:SetString("Fine")
    self.subtitle_gridsize1:SetColour(0,0,0,1)

    self.subtitle_gridsize2 = self.proot:AddChild(Text(NEWFONT_SMALL, 18))
    self.subtitle_gridsize2:SetPosition(178, -100, 0)
    self.subtitle_gridsize2:SetString("Wall")
    self.subtitle_gridsize2:SetColour(0,0,0,1)

    self.subtitle_gridsize3 = self.proot:AddChild(Text(NEWFONT_SMALL, 18))
    self.subtitle_gridsize3:SetPosition(231, -100, 0)
    self.subtitle_gridsize3:SetString("Sandbag")
    self.subtitle_gridsize3:SetColour(0,0,0,1)

    self.subtitle_gridsize4 = self.proot:AddChild(Text(NEWFONT_SMALL, 18))
    self.subtitle_gridsize4:SetPosition(284, -100, 0)
    self.subtitle_gridsize4:SetString("Turf")
    self.subtitle_gridsize4:SetColour(0,0,0,1)

	self.horizontal_line = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
	self.horizontal_line:SetScale(1.7, .38)
	self.horizontal_line:SetPosition(0, 60)
	
	--[[  Color Buttons   ]]--
	
	local colors = {"redgreen", "redblue", "blackwhite", "blackwhiteoutline"}
	self.color_buttons = {
		redgreen = { text = "Red/Green", hover = "The standard red and green that the normal game uses."},
		redblue = { text = "Red/Blue", hover = "Substitutes blue in place of the green,\nhelpful for the red/green colorblind."},
		blackwhite = { text = "Black/White", hover = "Black for blocked and white for placeable,\nusually more visible."},
		blackwhiteoutline = { text = "Outlined", hover = "Black and white, but with outlines for improved visibility."},
	}
    local button_y = 20
	for i, color_option in pairs(colors) do
		local button_params = self.color_buttons[color_option]
		local button = self.proot:AddChild(TEMPLATES.Button(button_params.text,
			function()
				for color_name,color_button in pairs(self.color_buttons) do
					if color_name == color_option then
						color_button:Select()
					else
						color_button:Unselect()
					end
				end
				self.callbacks.color(color_option)
			end))
		button:SetTextSize(35)
		button:SetPosition(0, button_y)
		button:SetScale(.7)
		button.leftanim = button:AddChild(UIAnim())
		button.leftanim:GetAnimState():SetBuild("buildgridplacer")
		button.leftanim:GetAnimState():SetBank("buildgridplacer")
		button.leftanim:GetAnimState():PlayAnimation("idle", true)
		button.leftanim:GetAnimState():SetLightOverride(1)
		button.leftanim:SetRotation(45)
		button.leftanim:SetPosition(-90, 0)
		button.rightanim = button:AddChild(UIAnim())
		button.rightanim:GetAnimState():SetBuild("buildgridplacer")
		button.rightanim:GetAnimState():SetBank("buildgridplacer")
		button.rightanim:GetAnimState():PlayAnimation("idle", true)
		button.rightanim:GetAnimState():SetLightOverride(1)
		button.rightanim:SetRotation(45)
		button.rightanim:SetPosition(80, 0)
		button_y = button_y - 45
		self.color_buttons[color_option] = button
	end
	
	--[[ Geometry Buttons ]]--
	
	self.geometry_buttons = {}
	local geometries = {
		{name="Square", hover="Aligned with the world's X-Z coordinate system.\nWalls and turf always use this geometry."},
		{name="Diamond", hover="Square rotated 45\176.\nLooks square from the default camera."},
		{name="X Hexagon", hover="Hexagon with a flat top parallel to the X axis."},
		{name="Flat Hexagon", hover="Hexagon with a flat top from the default camera."},
		{name="Z Hexagon", hover="Hexagon with a flat top parallel to the Z axis."},
		{name="Pointy Hexagon", hover="Hexagon with a pointy top from the default camera."},
	}
	for i,geometry in ipairs(geometries) do
		local geometry_option = geometry.name:gsub(" ", "_"):upper()
		local geometry_filename = geometry_option:lower() .. "_geometry"
		local button = self.proot:AddChild(TEMPLATES.IconButton(
			"images/"..geometry_filename..".xml",
			geometry_filename..".tex",
			geometry.hover, false, false,
			function()
				for geometry_name,geometry_button in pairs(self.geometry_buttons) do
					if geometry_name:upper() == geometry_option then
						geometry_button:Select()
					else
						geometry_button:Unselect()
					end
				end
				self.callbacks.geometry(geometry_option)
			end,
			{offset_y=60}))
		button.icon:SetScale(.7)
		self.geometry_buttons[geometry_option:lower()] = button
		button:SetPosition(((i+1)%2)*90-245, -10-math.floor((i-1)/2)*60)
	end
	
	--[[   Misc Buttons   ]]--
	
	local toggle_strings = {[true] = "Turn the mod off, except when holding control.",
							[false]= "Turn the mod on, except when holding control."}
	local toggle_state = true
	self.toggle_button = self.proot:AddChild(TEMPLATES.IconButton(
		"images/frontend.xml",
		"button_square_highlight.tex",
		toggle_strings[true], false, false,
		function()
			toggle_state = not toggle_state
			self.toggle_button.text:SetString(toggle_state and "On" or "Off")
			self.toggle_button.image:SetTint(toggle_state and .5 or 1, toggle_state and 1 or .5, .5, 1)
			self.toggle_button.hovertext:SetString(toggle_strings[toggle_state])
			self.callbacks.toggle(toggle_state)
		end,
		{offset_y=60}))
	self.toggle_button.icon:Hide()
	self.toggle_button:SetTextSize(30)
	self.toggle_button:SetText("On")
	self.toggle_button.text:SetPosition(-3, 5)
	self.toggle_button.image:SetTint(.5, 1, .5, 1)
	self.toggle_button:SetPosition(240, 135)
	
	local toggle_buttons = {
		{name="grid", hover="Whether to show the build grid.", toggle=1},
		{name="placer", hover="Whether to show the placer.\n(The ghost version of the thing you're placing)", toggle=1},
		{name="cursor", hover="Whether to show the item on the cursor,\njust the number, or nothing.", toggle=2},
	}
	for i,button in ipairs(toggle_buttons) do
		local btn = button.name.."_button"
		button.toggle_states = button.toggle + 1
		local atlas = "images/"..button.name.."_toggle_icon.xml"
		local texture = button.name.."_toggle_icon.tex"
		local alt_atlas = "images/"..button.name.."_toggle_icon"..(button.name == "cursor" and "_num" or "")..".xml"
		local alt_texture = button.name.."_toggle_icon"..(button.name == "cursor" and "_num" or "")..".tex"
		self[btn] = self.proot:AddChild(TEMPLATES.IconButton(atlas, texture, button.hover, false, false,
			function()
				button.toggle = (button.toggle - 1)%button.toggle_states
				if button.toggle == button.toggle_states-1 then
					self[btn].xout:Hide()
					self[btn].image:SetTint(.5, 1, .5, 1)
					self[btn].icon:SetTexture(atlas, texture)
				elseif button.toggle == 0 then
					self[btn].xout:Show()
					self[btn].image:SetTint(1, .5, .5, 1)
					self[btn].icon:SetTexture(atlas, texture)
				else --only used by cursor button
					self[btn].xout:Hide()
					self[btn].image:SetTint(1, 1, .5, 1)
					self[btn].icon:SetTexture(alt_atlas, alt_texture)
				end
				self.callbacks[button.name](button.toggle)
			end,
			{offset_y=60}))
		self[btn].icon:SetScale(.7)
		self[btn]:SetPosition(85 + 60*i, 22)
		self[btn].image:SetTint(.5, 1, .5, 1)
		self[btn].xout = self[btn]:AddChild(Image("images/toggle_x_out.xml", "toggle_x_out.tex"))
		self[btn].xout:SetScale(.8)
		self[btn].xout:SetPosition(-3,4)
		self[btn].xout:Hide()
		self[btn].highlight:MoveToFront() -- put it in front of the X
	end
	
	local percent_options = {}
	for i = 1, 10 do percent_options[i] = {text = i.."0%", data = i/10} end
	percent_options[11] = {text = "Unlimited", data = false}
	self.refresh = self.proot:AddChild(Spinner(percent_options, 100, 30, {font=NEWFONT_SMALL,size=18}, false, nil, nil, true, nil, nil, .76, .68))
	self.refresh.OnChanged = function(_, data) self.callbacks.refresh(data) end
	self.refresh:SetPosition(260, -30)
	-- a little switcharoo to get the right parenting to happen in SetHoverText
	local refreshtext = self.refresh.text
	self.refresh.text = nil
	self.refresh:SetHoverText(
		"How quickly to refresh the grid.\nTurning it up will make it more responsive, but it may cause lag.",
		{font = NEWFONT_OUTLINE, size = 22, offset_x = -4, offset_y = 45, colour = {1,1,1,1}})
	self.refresh.text = refreshtext

	local smallgridsizeoptions = {}
	for i=1,10 do smallgridsizeoptions[i] = {text=""..(i*2).."", data=i*2} end
	self.smallgrid = self.proot:AddChild(Spinner(smallgridsizeoptions, 60, 30, {font=NEWFONT_SMALL,size=18}, false, nil, nil, true, nil, nil, .76, .68))
	self.smallgrid.OnChanged = function(_, data) self.callbacks.gridsize(1, data) end
	self.smallgrid:SetPosition(125, -120)
	local medgridsizeoptions = {}
	for i=1,10 do medgridsizeoptions[i] = {text=""..(i).."", data=i} end
	self.medgrid = self.proot:AddChild(Spinner(medgridsizeoptions, 60, 30, {font=NEWFONT_SMALL,size=18}, false, nil, nil, true, nil, nil, .76, .68))
	self.medgrid.OnChanged = function(_, data) self.callbacks.gridsize(2, data) end
	self.medgrid:SetPosition(178, -120)
	local floodgridsizeoptions = {}
	for i=1,10 do floodgridsizeoptions[i] = {text=""..(i).."", data=i} end
	self.floodgrid = self.proot:AddChild(Spinner(floodgridsizeoptions, 60, 30, {font=NEWFONT_SMALL,size=18}, false, nil, nil, true, nil, nil, .76, .68))
	self.floodgrid.OnChanged = function(_, data) self.callbacks.gridsize(3, data) end
	self.floodgrid:SetPosition(231, -120)
	local biggridsizeoptions = {}
	for i=1,5 do biggridsizeoptions[i] = {text=""..(i).."", data=i} end
	self.biggrid = self.proot:AddChild(Spinner(biggridsizeoptions, 60, 30, {font=NEWFONT_SMALL,size=18}, false, nil, nil, true, nil, nil, .76, .68))
	self.biggrid.OnChanged = function(_, data) self.callbacks.gridsize(4, data) end
	self.biggrid:SetPosition(284, -120)


	--[[ Button Focus Hookups ]]--
    if not TheInput:ControllerAttached() then
        self.close_button = self.proot:AddChild(TEMPLATES.SmallButton("Close", 26, .5, function() self:Close() end))
        self.close_button:SetPosition(0, -170)
	else
		self.last_focus = self.toggle_button
		self.default_focus = self.toggle_button
		self.current_focus = self.toggle_button
		self.toggle_button:SetFocus()
    end
	-- Set up a table to know what section each button is in
	self.section_lookup = {
		[self.toggle_button] = 1,
		[self.refresh] = 4,
		[self.smallgrid] = 4,
		[self.medgrid] = 4,
		[self.floodgrid] = 4,
		[self.biggrid] = 4,
	}
	for _,button in pairs(self.geometry_buttons) do
		self.section_lookup[button] = 2
	end
	for _,button in pairs(self.color_buttons) do
		self.section_lookup[button] = 3
	end
	for _,button in pairs(toggle_buttons) do
		self.section_lookup[self[button.name.."_button"]] = 4
	end
	-- Set up a table to know what button to focus when switching sections
	self.section_mainbuttons = {self.toggle_button, self.geometry_buttons.square, self.color_buttons.redgreen, self.grid_button}

	for button,section in pairs(self.section_lookup) do
		local OldSetFocus = button.SetFocus
		button.SetFocus = function(button)
			self.current_focus = button or self.current_focus
			OldSetFocus(button)
		end
	end

	self.toggle_button:SetFocusChangeDir(MOVE_DOWN, self.cursor_button)
	self.toggle_button:SetFocusChangeDir(MOVE_LEFT, self.geometry_buttons.square)
	self.toggle_button:SetFocusChangeDir(MOVE_RIGHT, self.cursor_button)

	--Within geometry
	self.geometry_buttons.square:SetFocusChangeDir(MOVE_UP, self.toggle_button)
	self.geometry_buttons.square:SetFocusChangeDir(MOVE_RIGHT, self.geometry_buttons.diamond)
	self.geometry_buttons.square:SetFocusChangeDir(MOVE_DOWN, self.geometry_buttons.x_hexagon)
	self.geometry_buttons.diamond:SetFocusChangeDir(MOVE_UP, self.toggle_button)
	self.geometry_buttons.diamond:SetFocusChangeDir(MOVE_LEFT, self.geometry_buttons.square)
	self.geometry_buttons.diamond:SetFocusChangeDir(MOVE_DOWN, self.geometry_buttons.flat_hexagon)
	self.geometry_buttons.x_hexagon:SetFocusChangeDir(MOVE_UP, self.geometry_buttons.square)
	self.geometry_buttons.x_hexagon:SetFocusChangeDir(MOVE_RIGHT, self.geometry_buttons.flat_hexagon)
	self.geometry_buttons.x_hexagon:SetFocusChangeDir(MOVE_DOWN, self.geometry_buttons.z_hexagon)
	self.geometry_buttons.flat_hexagon:SetFocusChangeDir(MOVE_UP, self.geometry_buttons.diamond)
	self.geometry_buttons.flat_hexagon:SetFocusChangeDir(MOVE_LEFT, self.geometry_buttons.x_hexagon)
	self.geometry_buttons.flat_hexagon:SetFocusChangeDir(MOVE_DOWN, self.geometry_buttons.pointy_hexagon)
	self.geometry_buttons.z_hexagon:SetFocusChangeDir(MOVE_UP, self.geometry_buttons.x_hexagon)
	self.geometry_buttons.z_hexagon:SetFocusChangeDir(MOVE_RIGHT, self.geometry_buttons.pointy_hexagon)
	self.geometry_buttons.pointy_hexagon:SetFocusChangeDir(MOVE_UP, self.geometry_buttons.flat_hexagon)
	self.geometry_buttons.pointy_hexagon:SetFocusChangeDir(MOVE_LEFT, self.geometry_buttons.z_hexagon)
	
	--Geometry to colors
	self.geometry_buttons.flat_hexagon:SetFocusChangeDir(MOVE_RIGHT, self.color_buttons.blackwhite)
	self.color_buttons.blackwhite:SetFocusChangeDir(MOVE_LEFT, self.geometry_buttons.flat_hexagon)
	self.geometry_buttons.pointy_hexagon:SetFocusChangeDir(MOVE_RIGHT, self.color_buttons.blackwhiteoutline)
	self.color_buttons.blackwhiteoutline:SetFocusChangeDir(MOVE_LEFT, self.geometry_buttons.pointy_hexagon)
	self.geometry_buttons.diamond:SetFocusChangeDir(MOVE_RIGHT, self.color_buttons.redgreen)
	self.color_buttons.redgreen:SetFocusChangeDir(MOVE_LEFT, self.geometry_buttons.diamond)
	self.color_buttons.redblue:SetFocusChangeDir(MOVE_LEFT, self.geometry_buttons.diamond)
	
	--Within colors
	self.color_buttons.redgreen:SetFocusChangeDir(MOVE_UP, self.toggle_button)
	self.color_buttons.redgreen:SetFocusChangeDir(MOVE_DOWN, self.color_buttons.redblue)
	self.color_buttons.redblue:SetFocusChangeDir(MOVE_UP, self.color_buttons.redgreen)
	self.color_buttons.redblue:SetFocusChangeDir(MOVE_DOWN, self.color_buttons.blackwhite)
	self.color_buttons.blackwhite:SetFocusChangeDir(MOVE_UP, self.color_buttons.redblue)
	self.color_buttons.blackwhite:SetFocusChangeDir(MOVE_DOWN, self.color_buttons.blackwhiteoutline)
	self.color_buttons.blackwhiteoutline:SetFocusChangeDir(MOVE_UP, self.color_buttons.blackwhite)
	
	--Colors to misc
	self.color_buttons.redgreen:SetFocusChangeDir(MOVE_RIGHT, self.grid_button)
	self.grid_button:SetFocusChangeDir(MOVE_LEFT, self.color_buttons.redgreen)
	self.color_buttons.redblue:SetFocusChangeDir(MOVE_RIGHT, self.refresh)
	self.refresh:SetFocusChangeDir(MOVE_LEFT, self.color_buttons.redblue)
	self.color_buttons.blackwhite:SetFocusChangeDir(MOVE_RIGHT, self.smallgrid)
	self.smallgrid:SetFocusChangeDir(MOVE_LEFT, self.color_buttons.blackwhite)
	self.color_buttons.blackwhiteoutline:SetFocusChangeDir(MOVE_RIGHT, self.smallgrid)
	self.smallgrid:SetFocusChangeDir(MOVE_LEFT, self.color_buttons.blackwhiteoutline)
	
	--Within misc
	self.grid_button:SetFocusChangeDir(MOVE_UP, self.toggle_button)
	self.grid_button:SetFocusChangeDir(MOVE_RIGHT, self.placer_button)
	self.grid_button:SetFocusChangeDir(MOVE_DOWN, self.refresh)
	self.placer_button:SetFocusChangeDir(MOVE_UP, self.toggle_button)
	self.placer_button:SetFocusChangeDir(MOVE_LEFT, self.grid_button)
	self.placer_button:SetFocusChangeDir(MOVE_RIGHT, self.cursor_button)
	self.placer_button:SetFocusChangeDir(MOVE_DOWN, self.refresh)
	self.cursor_button:SetFocusChangeDir(MOVE_UP, self.toggle_button)
	self.cursor_button:SetFocusChangeDir(MOVE_LEFT, self.placer_button)
	self.cursor_button:SetFocusChangeDir(MOVE_DOWN, self.refresh)
	self.refresh:SetFocusChangeDir(MOVE_UP, self.cursor_button)
	self.refresh:SetFocusChangeDir(MOVE_DOWN, self.biggrid)
	self.smallgrid:SetFocusChangeDir(MOVE_UP, self.refresh)
	self.smallgrid:SetFocusChangeDir(MOVE_RIGHT, self.medgrid)
	self.medgrid:SetFocusChangeDir(MOVE_UP, self.refresh)
	self.medgrid:SetFocusChangeDir(MOVE_LEFT, self.smallgrid)
	self.medgrid:SetFocusChangeDir(MOVE_RIGHT, self.floodgrid)
	self.floodgrid:SetFocusChangeDir(MOVE_UP, self.refresh)
	self.floodgrid:SetFocusChangeDir(MOVE_LEFT, self.medgrid)
	self.floodgrid:SetFocusChangeDir(MOVE_RIGHT, self.biggrid)
	self.biggrid:SetFocusChangeDir(MOVE_UP, self.refresh)
	self.biggrid:SetFocusChangeDir(MOVE_LEFT, self.floodgrid)
	
	TheInputProxy:SetCursorVisible(true)
	self.default_focus = self.menu
end)

function GeometricOptionsScreen:OnFocusMove(dir, down)
	if not self.focus then return end
	if not self.section_lookup[TheFrontEnd:GetFocusWidget()] then
		--None of the widgets we want to be focusable are focused, the mouse probably stole it
		self.toggle_button:SetFocus()
		return true
	end
	return GeometricOptionsScreen._base.OnFocusMove(self, dir, down)
end

function GeometricOptionsScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_3) .. " " .. STRINGS.UI.HELP.BACK)
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_CRAFTING).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY).. " Change Section")
	
	return table.concat(t, "  ")
end

function GeometricOptionsScreen:OnRawKey(key, down)
	if GeometricOptionsScreen._base.OnRawKey(self, key, down) then return true end
	
	if self.IsOptionsMenuKey(key) and not down then	
		self.callbacks.ignore()
		self:Close()
		return true
	end
end

function GeometricOptionsScreen:OnControl(control, down)
	if GeometricOptionsScreen._base.OnControl(self,control, down) then return true end
	
	if down then return end
	if control == CONTROL_PAUSE or control == CONTROL_CANCEL or control == CONTROL_MENU_MISC_3 then
		self:Close()
		return true
	elseif TheInput:ControllerAttached() and (control == CONTROL_OPEN_CRAFTING or control == CONTROL_OPEN_INVENTORY) then
		local section = self.section_lookup[self.current_focus]
		if section then
			section = section + (control == CONTROL_OPEN_CRAFTING and -1 or 1)
		else
			section = 1
		end
		local focus = self.section_mainbuttons[((section-1)%#self.section_mainbuttons)+1]
		focus:SetFocus()
		return true
	end
end

function GeometricOptionsScreen:Close()
	self.active = false
	self.callbacks.save()
	TheFrontEnd:PopScreen() 
	SetPause(false)
	TheWorld:PushEvent("continuefrompause")
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
end

function GeometricOptionsScreen:OnUpdate(dt)
	if self.active then
		SetPause(true)
	end
end

function GeometricOptionsScreen:OnBecomeActive()
	GeometricOptionsScreen._base.OnBecomeActive(self)
	-- Hide the topfade, it'll obscure the pause menu if paused during fade. Fade-out will re-enable it
	TheFrontEnd:HideTopFade()
end

return GeometricOptionsScreen
