local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local pairs, type = pairs, type
local strfind = string.find
local r, g, b = DB.r, DB.g, DB.b

local function reskinChildButtons(frame)
	if not frame then return end

	for _, child in pairs {frame:GetChildren()} do
		if child:GetObjectType() == "Button" and child.Text then
			B.Reskin(child)
		end
	end
end

local function removeBorder(frame)
	for _, region in pairs {frame:GetRegions()} do
		if region:GetObjectType() == "Texture" then
			local texture = region.GetTexture and region:GetTexture()
			if texture and (texture == 130841 or strfind(texture, "Quickslot2")) then
				region:SetTexture("")
			end
		end
	end
end

local function SkinProfilingLine(line)
	if not line.styled then
		P.ReskinFont(line.spike, 12)
		P.ReskinFont(line.time, 12)
		P.ReskinFont(line.progressBar.name, 12)

		line.styled = true
	end
end

local function SkinProfilingFrame(frame)
	if not frame.styled then
		B.ReskinPortraitFrame(frame)
		S:Proxy("ReskinMinMax", frame.MaxMinButtonFrame)
		S:Proxy("StripTextures", frame.ScrollBox)
		S:Proxy("ReskinTrimScroll", frame.ScrollBar)

		hooksecurefunc(frame.ScrollBox, "Update", function(self)
			self:ForEachFrame(SkinProfilingLine)
		end)

		local buttons = frame.buttons
		if buttons then
			S:Proxy("Reskin", buttons.report)
			S:Proxy("Reskin", buttons.stop)
			P.ReskinDropDown(buttons.modeDropDown)

			local start = buttons.start
			if start then
				B.StripTextures(start)
				B.Reskin(start)
				start.Text:SetPoint("CENTER")
				B.SetupArrow(start.Icon, "right")
				start.Icon:SetPoint("RIGHT")
				start.Icon:SetSize(14, 14)
			end
		end

		local columnDisplay = frame.ColumnDisplay
		if columnDisplay and columnDisplay.columnHeaders then
			B.StripTextures(columnDisplay)
			for header in columnDisplay.columnHeaders:EnumerateActive() do
				if header:GetID() == 1 then
					header:SetPoint("BOTTOMLEFT", 3, 1)
				end

				B.StripTextures(header)
				local bg = B.CreateBDFrame(header, .25)
				bg:SetPoint("TOPLEFT", 4, -2)
				bg:SetPoint("BOTTOMRIGHT", 0, 2)

				header:SetHighlightTexture(DB.bdTex)
				local hl = header:GetHighlightTexture()
				hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
				hl:SetInside(bg)
			end
		end

		frame.styled = true
	end
end

local function SkinProfilingReport(frame)
	if not frame.styled then
		B.ReskinPortraitFrame(frame)

		local scrollBox = frame.ScrollBox
		if scrollBox then
			S:Proxy("ReskinTrimScroll", scrollBox.ScrollBar)
			S:Proxy("StripTextures", scrollBox.messageFrame)
			local bg = B.CreateBDFrame(scrollBox, .25)
			bg:SetPoint("TOPLEFT", -1, 2)
			bg:SetPoint("BOTTOMRIGHT", -22, -4)
		end

		frame.styled = true
	end
end

local function resetUrlBox(self)
	self:SetText(self.url)
	self:HighlightText()
	self:SetFocus()
end

local skinTips
local function WeakAurasSkinTips()
	if skinTips then skinTips:Show() return end

	skinTips = CreateFrame("Frame", "NDuiPlus_SkinTips", UIParent)
	tinsert(UISpecialFrames, "NDuiPlus_SkinTips")
	skinTips:SetPoint("CENTER")
	skinTips:SetSize(480, 200)
	skinTips:SetFrameStrata("HIGH")
	B.CreateMF(skinTips)
	B.SetBD(skinTips)
	B.CreateFS(skinTips, 16, L["WeakAuras Skins FAQ"], true, "TOP", 0, -8)
	local close = B.CreateButton(skinTips, 16, 16, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -6, -6)
	close:SetScript("OnClick", function()
		skinTips:Hide()
	end)
	local msg = strjoin(
		"\n",
		L["You are using Official WeakAuras, the skin of WeakAuras will not be loaded due to the limitation."],
		L["If you want to use WeakAuras skin, please install |cff99ccffWeakAurasPatched|r or change the code manually."],
		L["You can disable this alert via disabling WeakAuras Skin in |cff99ccffNDui|r Console."]
	)
	local fs = B.CreateFS(skinTips, 14, msg)
	fs:SetWordWrap(true)
	fs:SetJustifyH("LEFT")
	fs:SetSpacing(8)
	fs:ClearAllPoints()
	fs:SetPoint("TOPLEFT", 12, -40)
	fs:SetPoint("TOPRIGHT", -12, -40)
	local box = B.CreateEditBox(skinTips, 450, 22)
	box:SetPoint("BOTTOM", skinTips, "BOTTOM", 0, 22)
	box.url = "https://github.com/Witnesscm/NDui_Plus/wiki/WeakAuras2%E2%80%90Skins%E2%80%90FAQ"
	if DB.Client == "zhCN" or DB.Client == "zhTW" then
		box.url = "https://github.com/Witnesscm/NDui_Plus/wiki/WeakAuras2%E2%80%90%E7%9A%AE%E8%82%A4%E2%80%90%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98"
	end
	resetUrlBox(box)
	box:SetScript("OnTextChanged", resetUrlBox)
	box:SetScript("OnCursorChanged", resetUrlBox)
	local copy = B.CreateFS(skinTips, 12, L["Press Ctrl+C to copy the URL"])
	copy:ClearAllPoints()
	copy:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -2)
end

local LINK_ID = "WeakAurasTips"

hooksecurefunc("SetItemRef", function(link)
	local linkType, arg1, arg2 = strsplit(":", link)
	if linkType == "addon" and arg1 == addonName and arg2 == LINK_ID then
		WeakAurasSkinTips()
	end
end)

local function SkinWeakAurasOptions()
	local frame = _G.WeakAurasOptions
	if not frame or frame.styled then return end

	B.ReskinPortraitFrame(frame)
	S:Proxy("ReskinInput", frame.filterInput, 18)

	-- Minimize, Close Button
	B.ReskinClose(frame.CloseButton, frame)
	frame.CloseButton:SetSize(18, 18)
	B.ReskinMinMax(frame.MaxMinButtonFrame)
	frame.MaxMinButtonFrame:ClearAllPoints()
	frame.MaxMinButtonFrame:SetPoint("RIGHT", frame.CloseButton, "LEFT", 4, 0)
	frame.MaxMinButtonFrame.MaximizeButton:SetSize(18, 18)
	frame.MaxMinButtonFrame.MinimizeButton:SetSize(18, 18)

	-- ToolbarContainer
	local toolbarContainer = frame.toolbarContainer
	if toolbarContainer then
		local importButton, newButton, magnetButton, lockButton = toolbarContainer:GetChildren()
		newButton:ClearAllPoints()
		newButton:SetPoint("BOTTOMLEFT", frame.filterInput, "TOPLEFT", 0, 10)
		importButton:ClearAllPoints()
		importButton:SetPoint("LEFT", newButton, "RIGHT", 2, 0)
		lockButton:ClearAllPoints()
		lockButton:SetPoint("LEFT", importButton, "RIGHT", 2, 0)
		magnetButton:ClearAllPoints()
		magnetButton:SetPoint("LEFT", lockButton, "RIGHT", 2, 0)
	end

	-- Child Groups 
	-- texteditor, icon, texture, model, update, importexport, codereview, debuglog
	local childGroups = {}
	hooksecurefunc(frame, "UpdateFrameVisible", function()
		if frame.window == "default" then return end

		if not childGroups[frame.window] then
			for _, child in ipairs({frame:GetChildren()}) do
				local group = child.obj
				if group and group.Open and child:IsShown() then
					for _, child2 in pairs {child:GetChildren()} do
						local objType = child2:GetObjectType()
						if objType == "Button" and child2.Text then
							B.Reskin(child2)
						elseif objType == "EditBox" then
							B.ReskinInput(child2)
						end
					end

					if frame.window == "texteditor" then
						local snippets = _G.WeakAurasSnippets
						if snippets then
							P.ReskinFrame(snippets)
							reskinChildButtons(snippets)
						end
						local apiSearchFrame = _G.WeakAurasAPISearchFrame
						if apiSearchFrame then
							P.ReskinFrame(apiSearchFrame)
						end

						S:Proxy("Reskin", _G.WASettingsButton)
						S:Proxy("ReskinInput", _G.WeakAurasAPISearchFilterInput)
					elseif frame.window == "codereview" then
						local codebox = group.codebox
						local codeTree = group.codeTree
						if codebox and codeTree then
							codebox.frame:ClearAllPoints()
							codebox.frame:SetPoint("TOPLEFT", codeTree.content, 5, 0)
							codebox.frame:SetPoint("BOTTOMRIGHT", codeTree.content, -5, 0)
						end
					end

					childGroups[frame.window] = group
					break
				end
			end
		end
	end)

	-- Right Side Container
	local container = frame.container and frame.container.content and frame.container.content:GetParent()
	if container and container.bg then
		container.bg:Hide()
	end

	-- MoverSizer
	local moversizer = frame.moversizer
	if moversizer then
		moversizer:HideBackdrop()
		moversizer.__bg = B.CreateBDFrame(moversizer, 0)
		moversizer.__bg:SetScript("OnSizeChanged", nil)
		B.CreateSD(moversizer.__bg)

		local index = 1
		for _, child in pairs {moversizer:GetChildren()} do
			local numChildren = child:GetNumChildren()
			if numChildren == 2 and child:IsClampedToScreen() then
				local button1, button2 = child:GetChildren()
				if index == 1 then
					B.ReskinArrow(button1, "up")
					B.ReskinArrow(button2, "down")
				else
					B.ReskinArrow(button1, "left")
					B.ReskinArrow(button2, "right")
				end
				index = index + 1
			end
		end
	end

	-- TipPopup
	local tipPopup = frame.tipPopup
	if tipPopup then
		B.StripTextures(tipPopup)
		B.SetBD(tipPopup)

		for _, child in pairs {tipPopup:GetChildren()} do
			if child:GetObjectType() == "EditBox" then
				B.ReskinInput(child, 18)
			end
		end
	end

	local textCodesFrame = frame.dynamicTextCodesFrame
	if textCodesFrame then
		P.ReskinFrame(textCodesFrame)
	end

	frame.styled = true
end

-- Remove Options Aura Border (Credit: ElvUI_WindTools)
local function RemoveOptionsBorder(Private)
	if not Private.RegisterRegionOptions then return end

	local origRegisterRegionOptions = Private.RegisterRegionOptions
	Private.RegisterRegionOptions = function(name, createFunction, icon, displayName, createThumbnail, ...)
		if type(icon) == "function" then
			local OldIcon = icon
			icon = function()
				local f = OldIcon()
				removeBorder(f)
				return f
			end
		end

		if type(createThumbnail) == "function" then
			local OldCreateThumbnail = createThumbnail
			createThumbnail = function()
				local f = OldCreateThumbnail()
				removeBorder(f)
				return f
			end
		end

		return origRegisterRegionOptions(name, createFunction, icon, displayName, createThumbnail, ...)
	end
end

function S:WeakAuras()
	local WeakAuras = _G.WeakAuras
	if not WeakAuras then return end

	local profilingFrame = _G.WeakAurasProfilingFrame
	if profilingFrame then
		profilingFrame:HookScript("OnShow", SkinProfilingFrame)
	end

	local profilingReport = _G.WeakAurasProfilingReport
	if profilingReport then
		profilingReport:HookScript("OnShow", SkinProfilingReport)
	end

	if C.db["Skins"]["WeakAuras"] and not WeakAuras.Private then
		local link = format("|cff99ccff|Haddon:%s:%s|h[%s]|h|r", addonName, LINK_ID, L["Click for details"])
		P:Print(L["WeakAurasSkinTips"], link)
	end
end

function S:WeakAurasOptions()
	local WeakAuras = _G.WeakAuras
	if not WeakAuras then return end

	if WeakAuras.ShowOptions then
		hooksecurefunc(WeakAuras, "ShowOptions", SkinWeakAurasOptions)
	end

	if WeakAuras.ToggleOptions then
		local privateHooked
		local origToggleOptions = WeakAuras.ToggleOptions
		WeakAuras.ToggleOptions = function(...)
			local _, private = ...
			if private and not privateHooked then
				RemoveOptionsBorder(private)
				privateHooked = true
			end

			return origToggleOptions(...)
		end
	end
end

function S:WeakAurasTemplates()
	local WeakAuras = _G.WeakAuras
	if not WeakAuras or not WeakAuras.CreateTemplateView then return end

	local origCreateTemplateView = WeakAuras.CreateTemplateView
	WeakAuras.CreateTemplateView = function(...)
		local group = origCreateTemplateView(...)
		reskinChildButtons(group.frame)

		return group
	end
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

function S:WeakAurasDisplayButton(widget)
	local button = widget.frame

	P.ReskinCollapse(widget.expand)
	widget.expand:SetPushedTexture(0)
	widget.expand.SetPushedTexture = B.Dummy
	B.ReskinInput(widget.renamebox)
	button.group.texture:SetTexture(P.RotationRightTex)

	widget.icon:ClearAllPoints()
	widget.icon:SetPoint("LEFT", widget.frame, "LEFT", 1, 0)
	button.iconBG = B.CreateBDFrame(widget.icon, 0)
	button.iconBG:SetAllPoints(widget.icon)

	button.highlight:SetTexture(DB.bdTex)
	button.highlight:SetVertexColor(r, g, b, .25)
	button.highlight:SetInside()

	hooksecurefunc(widget, "SetIcon", S.WeakAuras_SkinIcon)
	hooksecurefunc(widget, "UpdateThumbnail", S.WeakAuras_UpdateIcon)
end

function S:WeakAurasNewButton(widget)
	local button = widget.frame

	widget.icon:SetTexCoord(unpack(DB.TexCoord))
	widget.icon:ClearAllPoints()
	widget.icon:SetPoint("LEFT", button, "LEFT", 1, 0)
	button.iconBG = B.CreateBDFrame(widget.icon, 0)
	button.iconBG:SetAllPoints(widget.icon)

	button.highlight:SetTexture(DB.bdTex)
	button.highlight:SetVertexColor(r, g, b, .25)
	button.highlight:SetInside()
end

function S:WeakAurasPendingUpdateButton(widget)
	local button = widget.frame

	widget.icon:SetTexCoord(unpack(DB.TexCoord))
	widget.icon:ClearAllPoints()
	widget.icon:SetPoint("LEFT", button, "LEFT", 1, 0)
	button.iconBG = B.CreateBDFrame(widget.icon, 0)
	button.iconBG:SetAllPoints(widget.icon)

	hooksecurefunc(widget, "SetIcon", S.WeakAuras_SkinIcon)
	hooksecurefunc(widget, "UpdateThumbnail", S.WeakAuras_UpdateIcon)
end

function S:WeakAurasMultiLineEditBox(widget)
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
end

function S:WeakAurasLoadedHeaderButton(widget)
	P.ReskinCollapse(widget.expand)
	widget.expand:SetPushedTexture(0)
	widget.expand.SetPushedTexture = B.Dummy
end

function S:WeakAurasIconButton(widget)
	local bg = B.ReskinIcon(widget.texture)
	bg:SetBackdropColor(0, 0, 0, 0)
	local hl = widget.frame:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetAllPoints()
end

function S:WeakAurasTextureButton(widget)
	local button = widget.frame
	B.CreateBD(button, .25)
	button:SetHighlightTexture(DB.bdTex)
	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(r, g, b, .25)
	hl:SetInside()
end

local function reskinStepper(stepper, direction)
	B.StripTextures(stepper)
	stepper:SetWidth(19)

	local tex = stepper:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	B.SetupArrow(tex, direction)
	stepper.__texture = tex

	stepper:HookScript("OnEnter", B.Texture_OnEnter)
	stepper:HookScript("OnLeave", B.Texture_OnLeave)
end

function S:WeakAurasSpinBox(widget)
	local frame = widget.frame
	local editbox = widget.editbox

	B.StripTextures(editbox)
	local bg = B.CreateBDFrame(frame, 0, true)
	bg:SetPoint("TOPLEFT", editbox, "TOPLEFT", -6, -1)
	bg:SetPoint("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", 2, 1)
	local bar = frame:CreateTexture(nil, "ARTWORK")
	bar:SetTexture(DB.normTex)
	bar:SetVertexColor(1, .8, 0, .8)
	bar:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
	bar:SetPoint("BOTTOMLEFT", bg, C.mult, C.mult)
	bar:SetPoint("RIGHT", widget.progressBar, "RIGHT")
	local thumb = frame:CreateTexture(nil, "ARTWORK")
	thumb:SetTexture(DB.sparkTex)
	thumb:SetBlendMode("ADD")
	thumb:SetSize(20, 36)
	thumb:SetPoint("CENTER", widget.progressBarHandle, "CENTER")
	reskinStepper(widget.leftbutton, "left")
	reskinStepper(widget.rightbutton, "right")
end

function S:WeakAurasSnippetButton(widget)
	B.ReskinInput(widget.renameEditBox)
	widget.renameEditBox.__bg:SetPoint("TOPLEFT", -2, 2)
	widget.renameEditBox.__bg:SetPoint("BOTTOMRIGHT", 0, -2)
end

function S:WeakAurasTreeGroup(widget)
	S:Ace3_Frame(widget)
	widget.treeframe:GetChildren():HideBackdrop()
end

function S:WA_LSM30_StatusbarAtlas(widget)
	S:Ace3_LibSharedMedia(widget)
end

S:RegisterSkin("WeakAuras", S.WeakAuras)
S:RegisterSkin("WeakAurasOptions", S.WeakAurasOptions)
S:RegisterSkin("WeakAurasTemplates", S.WeakAurasTemplates)
S:RegisterAceGUIWidget("WeakAurasDisplayButton")
S:RegisterAceGUIWidget("WeakAurasNewButton")
S:RegisterAceGUIWidget("WeakAurasPendingUpdateButton")
S:RegisterAceGUIWidget("WeakAurasMultiLineEditBox")
S:RegisterAceGUIWidget("WeakAuras-MultiLineEditBoxWithEnter", S.WeakAurasMultiLineEditBox)
S:RegisterAceGUIWidget("WeakAurasLoadedHeaderButton")
S:RegisterAceGUIWidget("WeakAurasIconButton")
S:RegisterAceGUIWidget("WeakAurasTextureButton")
S:RegisterAceGUIWidget("WeakAurasSpinBox")
S:RegisterAceGUIWidget("WeakAurasSnippetButton")
S:RegisterAceGUIWidget("WA_LSM30_StatusbarAtlas")
S:RegisterAceGUIContainer("WeakAurasTreeGroup")