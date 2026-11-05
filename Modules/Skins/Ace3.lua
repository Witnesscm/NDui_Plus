local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
----------------------------
-- Credit: ElvUI, ElvUI_WindTools
----------------------------
local _G = getfenv(0)
local select, pairs, type = select, pairs, type
local cr, cg, cb = DB.r, DB.g, DB.b

-- versions of AceGUI and AceConfigDialog.
local minorGUI, minorConfigDialog = 36, 76

function S:Ace3()
	local AceGUI = _G.LibStub and _G.LibStub("AceGUI-3.0", true)

	if not AceGUI then return end
	if not S.db["Ace3"] then return end

	for _, n in next, S.EarlyAceWidgets do
		if n.SetLayout then
			S:Ace3_RegisterAsContainer(n)
		else
			S:Ace3_RegisterAsWidget(n)
		end
	end

	for _, n in next, S.EarlyAceTooltips do
		S:Ace3_SkinTooltip(_G.LibStub(n, true))
	end
end

function S:Ace3_SkinSlider()
	self:HideBackdrop()
	self:SetWidth(16)

	local thumb = self.GetThumbTexture and self:GetThumbTexture()
	if thumb then
		thumb:SetAlpha(0)
		thumb:SetWidth(16)
		self.thumb = thumb

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetPoint("TOPLEFT", thumb, 0, -2)
		bg:SetPoint("BOTTOMRIGHT", thumb, 0, 4)
		bg:SetBackdropColor(cr, cg, cb, .75)
	end
end

function S:Ace3_SkinDropdown()
	local pullout = self and self.obj and self.obj.dropdown
	if pullout and not pullout.styled then
		P.ReskinTooltip(pullout)
		if pullout.SetBackdrop then pullout.SetBackdrop = B.Dummy end

		local slider = pullout.slider
		if slider then
			S.Ace3_SkinSlider(slider)
			slider:ClearAllPoints()
			slider:SetPoint("TOPRIGHT", pullout, "TOPRIGHT", -8, -10)
			slider:SetPoint("BOTTOMRIGHT", pullout, "BOTTOMRIGHT", -8, 10)
			slider:SetWidth(16)
		end

		pullout.styled = true
	end
end

function S:Ace3_SkinTab(tab)
	B.StripTextures(tab)
	tab.bg = B.CreateBDFrame(tab)
	tab.bg:SetPoint("TOPLEFT", 8, -3)
	tab.bg:SetPoint("BOTTOMRIGHT", -8, 0)
	tab.text:SetPoint("LEFT", 14, -1)

	tab:HookScript("OnEnter", B.Texture_OnEnter)
	tab:HookScript("OnLeave", B.Texture_OnLeave)
	hooksecurefunc(tab, "SetSelected", function(self, selected)
		if selected then
			self.bg:SetBackdropColor(cr, cg, cb, .25)
		else
			self.bg:SetBackdropColor(0, 0, 0, .25)
		end
	end)
end

function S:Ace3_RegisterAsWidget(widget)
	if self.aceWidgets[widget.type] then
		self.aceWidgets[widget.type](self, widget)
	end
end

function S:Ace3_RegisterAsContainer(widget)
	if self.aceContainers[widget.type] then
		self.aceContainers[widget.type](self, widget)
	end
end

function S:Ace3_Button(widget)
	B.Reskin(widget.frame)
end

function S:Ace3_CheckBox(widget)
	local check = widget.check
	local checkbg = widget.checkbg
	local highlight = widget.highlight

	local bg = B.CreateBDFrame(checkbg, 0)
	bg:SetInside(checkbg, 4, 4)
	B.CreateGradient(bg)
	bg:SetFrameLevel(bg:GetFrameLevel() + 1)
	checkbg:SetTexture(nil)
	checkbg.SetTexture = B.Dummy

	highlight:SetTexture(DB.bdTex)
	highlight:SetInside(bg)
	highlight:SetVertexColor(cr, cg, cb, .25)
	highlight.SetTexture = B.Dummy

	check:SetAtlas("checkmark-minimal")
	check:SetDesaturated(true)
	check:SetVertexColor(cr, cg, cb)
	check.SetDesaturated = B.Dummy

	hooksecurefunc(widget, "SetDisabled", function(self, disabled)
		local check = self.check
		if disabled then
			check:SetVertexColor(.8, .8, .8)
		else
			check:SetVertexColor(cr, cg, cb)
		end
	end)

	hooksecurefunc(widget, "SetType", function(self, type)
		if type == "radio" then
			bg:SetInside(checkbg, 3, 3)
			self.check:SetTexture(DB.bdTex)
			self.check:SetInside(bg)
		else
			bg:SetInside(checkbg, 4, 4)
			self.check:SetAtlas("checkmark-minimal")
			self.check:SetAllPoints(self.checkbg)
		end
	end)
end

function S:Ace3_Dropdown(widget)
	local frame = widget.dropdown
	local button = widget.button
	local text = widget.text

	B.StripTextures(frame)
	local bg = B.CreateBDFrame(frame, 0)
	bg:SetPoint("TOPLEFT", 18, -3)
	bg:SetPoint("BOTTOMRIGHT", -18, 3)
	B.CreateGradient(bg)

	widget.label:ClearAllPoints()
	widget.label:SetPoint("BOTTOMLEFT", bg, "TOPLEFT", 2, 0)

	B.ReskinArrow(button, "down")
	button:SetSize(20, 20)
	button:ClearAllPoints()
	button:SetPoint("RIGHT", bg)

	text:ClearAllPoints()
	text:SetJustifyH("RIGHT")
	text:SetPoint("RIGHT", button, "LEFT", -3, 0)
end

function S:Ace3_EditBox(widget)
	B.Reskin(widget.button)
	P.ReskinInput(widget.editbox)
	widget.editbox.bg:SetPoint("TOPLEFT", 0, -2)
	widget.editbox.bg:SetPoint("BOTTOMRIGHT", 0, 2)

	hooksecurefunc(widget.editbox, "SetPoint", function(self, a, b, c, d, e)
		if d == 7 then
			self:SetPoint(a, b, c, 0, e)
		end
	end)
end

function S:Ace3_MultiLineEditBox(widget)
	B.StripTextures(widget.scrollBG)
	local bg = B.CreateBDFrame(widget.scrollBG, .8)
	bg:SetPoint("TOPLEFT", 0, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 1)
	B.Reskin(widget.button)
	B.ReskinScroll(widget.scrollBar)

	widget.scrollBar:SetPoint("RIGHT", widget.frame, "RIGHT", 0 -4)
	widget.scrollBG:SetPoint("TOPRIGHT", widget.scrollBar, "TOPLEFT", -2, 19)
	widget.scrollBG:SetPoint("BOTTOMLEFT", widget.button, "TOPLEFT")
	widget.scrollFrame:SetPoint("BOTTOMRIGHT", widget.scrollBG, "BOTTOMRIGHT", -4, 8)
end

function S:Ace3_Slider(widget)
	B.ReskinSlider(widget.slider)
	widget.editbox:HideBackdrop()
	B.ReskinInput(widget.editbox)
	widget.editbox:SetPoint("TOP", widget.slider, "BOTTOM", 0, -1)
end

function S:Ace3_Keybinding(widget)
	local button = widget.button
	local msgframe = widget.msgframe

	B.Reskin(button)
	B.StripTextures(msgframe)
	B.SetBD(msgframe)
	msgframe.msg:ClearAllPoints()
	msgframe.msg:SetPoint("CENTER")
end

function S:Ace3_ColorPicker(widget)
	local frame = widget.frame
	local colorSwatch = widget.colorSwatch
	local text = widget.text

	local bg = B.CreateBDFrame(frame)
	bg:SetSize(18, 18)
	bg:ClearAllPoints()
	bg:SetPoint("LEFT", frame, "LEFT", 4, 0)

	colorSwatch:SetTexture(DB.bdTex)
	colorSwatch:ClearAllPoints()
	colorSwatch:SetParent(bg)
	colorSwatch:SetInside(bg)

	if colorSwatch.background then
		colorSwatch.background:SetColorTexture(0, 0, 0, 0)
	end

	if colorSwatch.checkers then
		colorSwatch.checkers:ClearAllPoints()
		colorSwatch.checkers:SetParent(bg)
		colorSwatch.checkers:SetInside(bg)
	end

	text:ClearAllPoints()
	text:SetPoint("LEFT", colorSwatch, "RIGHT", 4, 0)
end

function S:Ace3_SetImage(path, ...)
	local image = self.image
	image:SetTexture(path)
	image.bg:Hide()

	if image:GetTexture() then
		local n = select("#", ...)
		if n == 4 or n == 8 then
			image:SetTexCoord(...)
		elseif tonumber(path) then
			image:SetTexCoord(unpack(DB.TexCoord))
			image.bg:Show()
		else
			image:SetTexCoord(0, 1, 0, 1)
		end
	end
end

function S:Ace3_Icon(widget)
	local button = widget.frame
	local image = widget.image

	image:SetTexCoord(unpack(DB.TexCoord))
	image.bg = B.CreateBDFrame(image, 0)

	B.StripTextures(button)
	button:SetHighlightTexture(DB.bdTex)
	button:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	button:GetHighlightTexture():SetInside(image.bg)

	widget.SetImage = S.Ace3_SetImage
end

function S:Ace3_DropdownPullout(widget)
	local frame = widget.frame
	P.ReskinTooltip(frame)
	frame.bg.SetFrameLevel = B.Dummy

	if widget.slider then
		S.Ace3_SkinSlider(widget.slider)
	end
end

function S:Ace3_LibSharedMedia(widget)
	local frame = widget.frame
	local button = frame.dropButton
	local text = frame.text

	B.StripTextures(frame)
	local bg = B.CreateBDFrame(frame, 0)
	bg:SetPoint("TOPLEFT", 3, -22)
	bg:SetPoint("BOTTOMRIGHT", -1, 2)
	B.CreateGradient(bg)

	frame.label:ClearAllPoints()
	frame.label:SetPoint("BOTTOMLEFT", bg, "TOPLEFT", 2, 0)

	B.ReskinArrow(button, "down")
	button:SetSize(20, 20)
	button:ClearAllPoints()
	button:SetPoint("RIGHT", bg)

	text:ClearAllPoints()
	text:SetPoint("RIGHT", button, "LEFT", -2, 0)

	if widget.type == "LSM30_Sound" then
		widget.soundbutton:SetParent(bg)
		widget.soundbutton:ClearAllPoints()
		widget.soundbutton:SetPoint("LEFT", bg, "LEFT", 2, 0)
	elseif widget.type == "LSM30_Statusbar" then
		widget.bar:SetParent(bg)
		widget.bar:ClearAllPoints()
		widget.bar:SetPoint("TOPLEFT", bg, "TOPLEFT", 2, -2)
		widget.bar:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -1, 0)
	elseif widget.type == "LSM30_Border" or widget.type == "LSM30_Background" then
		bg:SetPoint("TOPLEFT", 45, -22)
	end

	button:SetParent(bg)
	text:SetParent(bg)
	button:HookScript("OnClick", S.Ace3_SkinDropdown)
end

function S:Ace3_Frame(widget)
	local frame = widget.content:GetParent()
	B.StripTextures(frame)
	if widget.type == "Frame" then
		for i = 1, frame:GetNumChildren() do
			local child = select(i, frame:GetChildren())
			if child:GetObjectType() == "Button" and child:GetText() then
				B.Reskin(child)
			else
				B.StripTextures(child)
			end
		end
		B.SetBD(frame)
	else
		frame.bg = B.CreateBDFrame(frame, .25)
		frame.bg:SetPoint("TOPLEFT", 2, -2)
		frame.bg:SetPoint("BOTTOMRIGHT", -2, 2)
	end

	if widget.treeframe then
		local bg = B.CreateBDFrame(widget.treeframe, .25)
		bg:SetPoint("TOPLEFT", 2, -2)
		bg:SetPoint("BOTTOMRIGHT", -2, 2)

		local oldRefreshTree = widget.RefreshTree
		widget.RefreshTree = function(self, scrollToSelection)
			oldRefreshTree(self, scrollToSelection)
			if not self.tree then return end
			local status = self.status or self.localstatus
			local lines = self.lines
			local buttons = self.buttons
			local offset = status.scrollvalue

			for i = offset + 1, #lines do
				local button = buttons[i - offset]
				if button and not button.styled then
					local toggle = button.toggle
					P.ReskinCollapse(toggle)
					toggle.SetPushedTexture = B.Dummy
					button.styled = true
				end
			end
		end
	end

	if widget.scrollbar then
		B.ReskinScroll(widget.scrollbar)
		widget.scrollbar:DisableDrawLayer("BACKGROUND")
	end
end

function S:Ace3_Window(widget)
	S:Ace3_Frame(widget)
	B.ReskinClose(widget.closebutton)
end

function S:Ace3_TabGroup(widget)
	S:Ace3_Frame(widget)

	local oldCreateTab = widget.CreateTab
	widget.CreateTab = function(...)
		local tab = oldCreateTab(...)
		S:Ace3_SkinTab(tab)
		return tab
	end
end

function S:Ace3_ScrollFrame(widget)
	B.ReskinScroll(widget.scrollbar)
	widget.scrollbar:DisableDrawLayer("BACKGROUND")
end

function S:Ace3_MetaTable(lib)
	local t = getmetatable(lib)
	if t then
		t.__newindex = S.Ace3_MetaIndex
	else
		setmetatable(lib, {__newindex = S.Ace3_MetaIndex})
	end
end

function S:Ace3_MetaIndex(k, v)
	if k == "tooltip" then
		rawset(self, k, v)
		P.ReskinTooltip(v)
	elseif k == "popup" then
		rawset(self, k, v)
		v:HookScript("OnShow", S.Ace3_StylePopup)
		v.IsHooked = true
	elseif k == "RegisterAsContainer" then
		rawset(self, k, function(s, w, ...)
			if S.db["Ace3"] then
				S:Ace3_RegisterAsContainer(w, ...)
			end
			return v(s, w, ...)
		end)
	elseif k == "RegisterAsWidget" then
		rawset(self, k, function(s, w, ...)
			if S.db["Ace3"] then
				S:Ace3_RegisterAsWidget(w, ...)
			end
			return v(s, w, ...)
		end)
	else
		rawset(self, k, v)
	end
end

function S:Ace3_StylePopup()
	if not self:IsForbidden() and not self.styled then
		B.StripTextures(self)
		B.SetBD(self)

		for _, key in pairs({"accept", "cancel"}) do
			local bu = self[key]
			if bu then
				B.Reskin(bu)
			end
		end

		for _, child in pairs {self:GetChildren()} do
			if child.Bg and child.layoutType and child.layoutType == "Dialog" then
				B.StripTextures(child)
				break
			end
		end

		self.styled = true
	end
end

function S:Ace3_SkinTooltip(lib, minor) -- lib: AceConfigDialog or AceGUI
	if not lib or (minor and minor < minorConfigDialog) then return end

	if not lib.tooltip then
		S:Ace3_MetaTable(lib)
	else
		P.ReskinTooltip(lib.tooltip)

		if lib.popup and not lib.popup.IsHooked then -- StaticPopup
			lib.popup:HookScript("OnShow", S.Ace3_StylePopup)
		end
	end
end

local lastMinor = 0
function S:HookAce3(lib, minor, earlyLoad) -- lib: AceGUI
	if not lib or (not minor or minor < minorGUI) then return end

	local earlyContainer, earlyWidget
	local oldMinor = lastMinor
	if lastMinor < minor then
		lastMinor = minor
	end
	if earlyLoad then
		earlyContainer = lib.RegisterAsContainer
		earlyWidget = lib.RegisterAsWidget
	end
	if earlyLoad or oldMinor ~= minor then
		lib.RegisterAsContainer = nil
		lib.RegisterAsWidget = nil
	end

	if not lib.RegisterAsWidget then
		S:Ace3_MetaTable(lib)
	end

	if earlyContainer then lib.RegisterAsContainer = earlyContainer end
	if earlyWidget then lib.RegisterAsWidget = earlyWidget end
end

do -- Early Skin Loading
	local Libraries = {
		["AceGUI"] = true,
		["AceConfigDialog"] = true,
	}

	S.EarlyAceWidgets = {}
	S.EarlyAceTooltips = {}

	local LibStub = _G.LibStub
	if not LibStub then return end

	local numEnding = "%-[%d%.]+$"
	function S:LibStub_NewLib(major, minor)
		local earlyLoad = major == "ElvUI"
		if earlyLoad then major = minor end

		local n = gsub(major, numEnding, "")
		if Libraries[n] then
			if n == "AceGUI" then
				S:HookAce3(LibStub.libs[major], LibStub.minors[major], earlyLoad)
				if earlyLoad then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major])
				end
			elseif n == "AceConfigDialog" then
				if earlyLoad then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major], LibStub.minors[major])
				end
			end
		end
	end

	local findWidget
	local function earlyWidget(y)
		if y.children then findWidget(y.children) end
		if y.frame and (y.base and y.base.Release) then
			tinsert(S.EarlyAceWidgets, y)
		end
	end

	findWidget = function(x)
		for _, y in ipairs(x) do
			earlyWidget(y)
		end
	end

	for n in next, LibStub.libs do
		if n == "AceGUI-3.0" then
			for _, x in ipairs({_G.UIParent:GetChildren()}) do
				if x and x.obj then earlyWidget(x.obj) end
			end
		end
		if Libraries[gsub(n, numEnding, "")] then
			S:LibStub_NewLib("ElvUI", n)
		end
	end

	hooksecurefunc(LibStub, "NewLibrary", S.LibStub_NewLib)
end

S:RegisterSkin("Ace3")
S:RegisterAceGUIWidget("Button", S.Ace3_Button)
S:RegisterAceGUIWidget("MacroButton", S.Ace3_Button)
S:RegisterAceGUIWidget("CheckBox", S.Ace3_CheckBox)
S:RegisterAceGUIWidget("Dropdown", S.Ace3_Dropdown)
S:RegisterAceGUIWidget("LQDropdown", S.Ace3_Dropdown)
S:RegisterAceGUIWidget("SharedDropdown", S.Ace3_Dropdown)
S:RegisterAceGUIWidget("EditBox", S.Ace3_EditBox)
S:RegisterAceGUIWidget("MultiLineEditBox", S.Ace3_MultiLineEditBox)
S:RegisterAceGUIWidget("Slider", S.Ace3_Slider)
S:RegisterAceGUIWidget("Keybinding", S.Ace3_Keybinding)
S:RegisterAceGUIWidget("ColorPicker", S.Ace3_ColorPicker)
S:RegisterAceGUIWidget("Icon", S.Ace3_Icon)
S:RegisterAceGUIWidget("Dropdown-Pullout", S.Ace3_DropdownPullout)
S:RegisterAceGUIWidget("LSM30_Font", S.Ace3_LibSharedMedia)
S:RegisterAceGUIWidget("LSM30_Sound", S.Ace3_LibSharedMedia)
S:RegisterAceGUIWidget("LSM30_Border", S.Ace3_LibSharedMedia)
S:RegisterAceGUIWidget("LSM30_Background", S.Ace3_LibSharedMedia)
S:RegisterAceGUIWidget("LSM30_Statusbar", S.Ace3_LibSharedMedia)
S:RegisterAceGUIContainer("Frame", S.Ace3_Frame)
S:RegisterAceGUIContainer("InlineGroup", S.Ace3_Frame)
S:RegisterAceGUIContainer("TreeGroup", S.Ace3_Frame)
S:RegisterAceGUIContainer("DropdownGroup", S.Ace3_Frame)
S:RegisterAceGUIContainer("Window", S.Ace3_Window)
S:RegisterAceGUIContainer("TabGroup", S.Ace3_TabGroup)
S:RegisterAceGUIContainer("ScrollFrame", S.Ace3_ScrollFrame)