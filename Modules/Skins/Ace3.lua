local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
----------------------------
-- Credit: ElvUI
----------------------------
local _G = getfenv(0)
local select, pairs, type = select, pairs, type
local cr, cg, cb = DB.r, DB.g, DB.b
local TT = B:GetModule("Tooltip")

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

S:RegisterSkin("Ace3")

local function Scroll_OnEnter(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(cr, cg, cb, .25)
	thumb.bg:SetBackdropBorderColor(cr, cg, cb)
end

local function Scroll_OnLeave(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(0, 0, 0, 0)
	B.SetBorderColor(thumb.bg)
end

function S:Ace3_SkinSlider()
	self:SetBackdrop(nil)
	self:SetWidth(16)

	local thumb = self.GetThumbTexture and self:GetThumbTexture()
	if thumb then
		thumb:SetAlpha(0)
		thumb:SetWidth(16)
		self.thumb = thumb

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetPoint("TOPLEFT", thumb, 0, -2)
		bg:SetPoint("BOTTOMRIGHT", thumb, 0, 4)
		thumb.bg = bg
	end

	self:HookScript("OnEnter", Scroll_OnEnter)
	self:HookScript("OnLeave", Scroll_OnLeave)
end

function S:Ace3_SkinDropdown()
	if self and self.obj then
		local pullout = self.obj.dropdown
		if pullout then
			P.ReskinTooltip(pullout)
			if pullout.SetBackdrop then pullout:SetBackdrop(nil) end

			local slider = pullout.slider
			if slider and not slider.styled then
				S.Ace3_SkinSlider(slider)
				slider:ClearAllPoints()
				slider:SetPoint("TOPRIGHT", pullout, "TOPRIGHT", -8, -10)
				slider:SetPoint("BOTTOMRIGHT", pullout, "BOTTOMRIGHT", -8, 10)
				slider:SetWidth(16)

				slider.styled = true
			end
		end
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

local WeakAuras_RegionType = {
	["icon"] = true,
	["group"] = true,
	["dynamicgroup"] = true,
}

function S:WeakAuras_SkinIcon(icon)
	if type(icon) ~= "table" or not icon.icon then return end

	if WeakAuras_RegionType[self.data.regionType] then
		icon.icon:SetTexCoord(unpack(DB.TexCoord))
	end
end

function S:WeakAuras_UpdateIcon()
	if not self.thumbnail or not self.thumbnail.icon then return end

	if WeakAuras_RegionType[self.data.regionType] then
		self.thumbnail.icon:SetTexCoord(unpack(DB.TexCoord))
	end
end

function S:Ace3_RegisterAsWidget(widget)
	local TYPE = widget.type
	if TYPE == "MultiLineEditBox" then
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
	elseif TYPE == "CheckBox" then
		local check = widget.check
		local checkbg = widget.checkbg
		local highlight = widget.highlight

		local bg = B.CreateBDFrame(checkbg, 0)
		bg:SetPoint("TOPLEFT", checkbg, "TOPLEFT", 4, -4)
		bg:SetPoint("BOTTOMRIGHT", checkbg, "BOTTOMRIGHT", -4, 4)
		B.CreateGradient(bg)
		bg:SetFrameLevel(bg:GetFrameLevel() + 1)
		checkbg:SetTexture(nil)
		checkbg.SetTexture = B.Dummy

		highlight:SetTexture(DB.bdTex)
		highlight:SetPoint("TOPLEFT", checkbg, "TOPLEFT", 5, -5)
		highlight:SetPoint("BOTTOMRIGHT", checkbg, "BOTTOMRIGHT", -5, 5)
		highlight:SetVertexColor(cr, cg, cb, .25)
		highlight.SetTexture = B.Dummy

		check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		check:SetTexCoord(0, 1, 0, 1)
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
				self.check:SetTexture(DB.bdTex)
				self.check:SetInside(self.checkbg, 4, 4)
			else
				self.check:SetAllPoints(self.checkbg)
			end
		end)
	elseif TYPE == "Dropdown" or TYPE == "LQDropdown" then
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
	elseif TYPE == "LSM30_Font" or TYPE == "LSM30_Sound" or TYPE == "LSM30_Border" or TYPE == "LSM30_Background" or TYPE == "LSM30_Statusbar" then
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

		if TYPE == "LSM30_Sound" then
			widget.soundbutton:SetParent(bg)
			widget.soundbutton:ClearAllPoints()
			widget.soundbutton:SetPoint("LEFT", bg, "LEFT", 2, 0)
		elseif TYPE == "LSM30_Statusbar" then
			widget.bar:SetParent(bg)
			widget.bar:ClearAllPoints()
			widget.bar:SetPoint("TOPLEFT", bg, "TOPLEFT", 2, -2)
			widget.bar:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -1, 0)
		elseif TYPE == "LSM30_Border" or TYPE == "LSM30_Background" then
			bg:SetPoint("TOPLEFT", 45, -22)
		end

		button:SetParent(bg)
		text:SetParent(bg)
		button:HookScript("OnClick", S.Ace3_SkinDropdown)
	elseif TYPE == "EditBox" then
		B.Reskin(widget.button)
		P.ReskinInput(widget.editbox)
		widget.editbox.bg:SetPoint("TOPLEFT", 0, -2)
		widget.editbox.bg:SetPoint("BOTTOMRIGHT", 0, 2)

		hooksecurefunc(widget.editbox, "SetPoint", function(self, a, b, c, d, e)
			if d == 7 then
				self:SetPoint(a, b, c, 0, e)
			end
		end)
	elseif TYPE == "Button" or TYPE == "MacroButton" then
		B.Reskin(widget.frame)
	elseif TYPE == "Slider" then
		B.ReskinSlider(widget.slider)
		widget.editbox:SetBackdrop(nil)
		B.ReskinInput(widget.editbox)
		widget.editbox:SetPoint("TOP", widget.slider, "BOTTOM", 0, -1)
	elseif TYPE == "Keybinding" then
		local button = widget.button
		local msgframe = widget.msgframe

		B.Reskin(button)
		B.StripTextures(msgframe)
		B.SetBD(msgframe)
		msgframe.msg:ClearAllPoints()
		msgframe.msg:SetPoint("CENTER")
	elseif TYPE == "ColorPicker" then
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
	elseif TYPE == "Icon" then
		B.StripTextures(widget.frame)
	elseif TYPE == "Dropdown-Pullout" then
		local frame = widget.frame
		P.ReskinTooltip(frame)
		frame.bg.SetFrameLevel = B.Dummy

		if widget.slider then
			S.Ace3_SkinSlider(widget.slider)
		end
	elseif TYPE == "WeakAurasDisplayButton" then
		local button = widget.frame

		P.ReskinCollapse(widget.expand)
		widget.expand:SetPushedTexture("")
		widget.expand.SetPushedTexture = B.Dummy
		B.ReskinInput(widget.renamebox)
		button.group.texture:SetTexture(P.RotationRightTex)

		widget.icon:ClearAllPoints()
		widget.icon:SetPoint("LEFT", widget.frame, "LEFT", 1, 0)
		button.iconBG = B.CreateBDFrame(widget.icon, 0)
		button.iconBG:SetAllPoints(widget.icon)

		button.highlight:SetTexture(DB.bdTex)
		button.highlight:SetVertexColor(cr, cg, cb, .25)
		button.highlight:SetInside()

		hooksecurefunc(widget, "SetIcon", S.WeakAuras_SkinIcon)
		hooksecurefunc(widget, "UpdateThumbnail", S.WeakAuras_UpdateIcon)
	elseif TYPE == "WeakAurasNewButton" then
		local button = widget.frame

		widget.icon:SetTexCoord(unpack(DB.TexCoord))
		widget.icon:ClearAllPoints()
		widget.icon:SetPoint("LEFT", button, "LEFT", 1, 0)
		button.iconBG = B.CreateBDFrame(widget.icon, 0)
		button.iconBG:SetAllPoints(widget.icon)

		button.highlight:SetTexture(DB.bdTex)
		button.highlight:SetVertexColor(cr, cg, cb, .25)
		button.highlight:SetInside()
	elseif TYPE == "WeakAurasPendingUpdateButton" then
		local button = widget.frame

		widget.icon:SetTexCoord(unpack(DB.TexCoord))
		widget.icon:ClearAllPoints()
		widget.icon:SetPoint("LEFT", button, "LEFT", 1, 0)
		button.iconBG = B.CreateBDFrame(widget.icon, 0)
		button.iconBG:SetAllPoints(widget.icon)
	elseif TYPE == "WeakAurasMultiLineEditBox" then
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

		widget.frame:HookScript("OnShow", function()
			if widget.extraButtons then
				for _, button in next, widget.extraButtons do
					if not button.styled then
						B.Reskin(button)
						button.styled = true
					end
				end
			end
		end)
	elseif TYPE == "WeakAurasLoadedHeaderButton" then
		P.ReskinCollapse(widget.expand)
		widget.expand:SetPushedTexture("")
		widget.expand.SetPushedTexture = B.Dummy
	elseif TYPE == "WeakAurasIconButton" then
		local bg = B.ReskinIcon(widget.texture)
		bg:SetBackdropColor(0, 0, 0, 0)
		local hl = widget.frame:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints()
	elseif TYPE == "WeakAurasTextureButton" then
		local button = widget.frame

		B.CreateBD(button, .25)
		button:SetHighlightTexture(DB.bdTex)
		local hl = button:GetHighlightTexture()
		hl:SetVertexColor(cr, cg, cb, .25)
		hl:SetInside()
	end
end

function S:Ace3_RegisterAsContainer(widget)
	local TYPE = widget.type
	if TYPE == "ScrollFrame" then
		B.ReskinScroll(widget.scrollbar)
		widget.scrollbar:DisableDrawLayer("BACKGROUND")
	elseif TYPE == "InlineGroup" or TYPE == "TreeGroup" or TYPE == "TabGroup" or TYPE == "Frame" or TYPE == "DropdownGroup" or TYPE == "Window" or TYPE == "WeakAurasTreeGroup" then
		local frame = widget.content:GetParent()
		B.StripTextures(frame)
		if TYPE == "Frame" then
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

		if TYPE == "Window" then
			B.ReskinClose(frame.obj.closebutton)
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

		if TYPE == "TabGroup" then
			local oldCreateTab = widget.CreateTab
			widget.CreateTab = function(self, id)
				local tab = oldCreateTab(self, id)
				S:Ace3_SkinTab(tab)
				return tab
			end
		end

		if widget.scrollbar then
			B.ReskinScroll(widget.scrollbar)
			widget.scrollbar:DisableDrawLayer("BACKGROUND")
		end

		if TYPE == "WeakAurasTreeGroup" then
			local treeframe = widget.treeframe
			local treeframeBG = treeframe:GetChildren()
			treeframeBG:SetAlpha(0)
		end
	end
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
		TT.ReskinTooltip(v)
	elseif k == "popup" then
		rawset(self, k, v)
		v:HookScript("OnShow", S.Ace3_StylePopup)
		v.IsHooked = true
	elseif k == "RegisterAsContainer" then
		rawset(self, k, function(s, w, ...)
			if S.db["Ace3"] then
				S.Ace3_RegisterAsContainer(s, w, ...)
			end
			return v(s, w, ...)
		end)
	elseif k == "RegisterAsWidget" then
		rawset(self, k, function(...)
			if S.db["Ace3"] then
				S.Ace3_RegisterAsWidget(...)
			end
			return v(...)
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
		TT.ReskinTooltip(lib.tooltip)

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
