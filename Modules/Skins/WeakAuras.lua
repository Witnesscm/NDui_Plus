local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local select, pairs, type = select, pairs, type
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

local function SkinProfilingWindow(frame)
	B.ReskinPortraitFrame(frame)
	S:Proxy("ReskinMinMax", frame.MaxMinButtonFrame)
	reskinChildButtons(frame)
end

local function SkinPrintProfile()
	local frame = _G.WeakAurasProfilingReport
	if frame and not frame.styled then
		B.ReskinPortraitFrame(frame)

		local scrollFrame = frame.messageFrame and frame.messageFrame:GetParent()
		if scrollFrame then
			S:Proxy("ReskinScroll", scrollFrame.ScrollBar)
		end

		frame.styled = true
	end
end

local function SkinWeakAurasOptions()
	local frame = _G.WeakAurasOptions
	if not frame or frame.styled then return end

	B.ReskinPortraitFrame(frame)
	S:Proxy("ReskinInput", frame.filterInput, 18)
	S:Proxy("Reskin", _G.WASettingsButton)

	-- Minimize, Close Button
	B.ReskinClose(frame.CloseButton, frame)
	frame.CloseButton:SetSize(18, 18)
	B.ReskinMinMax(frame.MaxMinButtonFrame)
	frame.MaxMinButtonFrame:ClearAllPoints()
	frame.MaxMinButtonFrame:SetPoint("RIGHT", frame.CloseButton, "LEFT", 8, 0)
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
	local childGroups = {
		"texturePicker",
		"iconPicker",
		"modelPicker",
		"importexport",
		"texteditor",
		"codereview",
		"update",
		"debugLog",
	}

	for _, key in pairs(childGroups) do
		local group = frame[key]
		if group then
			reskinChildButtons(group.frame)
		end
	end

	-- TextEditor
	local texteditor = frame.texteditor and frame.texteditor.frame
	if texteditor then
		for _, child in pairs {texteditor:GetChildren()} do
			if child.GetObjectType and child:GetObjectType() == "EditBox" then
				B.ReskinInput(child)
				break
			end
		end
	end

	-- CodeReview
	local codereview = frame.codereview
	if codereview then
		hooksecurefunc(codereview, "Open", function(self)
			local codebox = self.codebox
			local codeTree = self.codeTree
			if codebox and codeTree then
				codebox.frame:ClearAllPoints()
				codebox.frame:SetPoint("TOPLEFT", codeTree.content, 5, 0)
				codebox.frame:SetPoint("BOTTOMRIGHT", codeTree.content, -5, 0)
			end
		end)
	end

	-- IconPicker
	local iconPicker = frame.iconPicker and frame.iconPicker.frame
	if iconPicker then
		for _, child in pairs {iconPicker:GetChildren()} do
			if child:GetObjectType() == "EditBox" then
				B.ReskinInput(child, 20)
			end
		end
	end

	-- ModelPicker
	local modelPicker = frame.modelPicker and frame.modelPicker.frame
	if modelPicker and modelPicker.filterInput then
		B.ReskinInput(modelPicker.filterInput, 18)
	end

	-- Right Side Container
	local container = frame.container and frame.container.content and frame.container.content:GetParent()
	if container and container.bg then
		container.bg:Hide()
	end

	-- WeakAurasSnippets
	local snippets = _G.WeakAurasSnippets
	if snippets then
		B.StripTextures(snippets)
		B.SetBD(snippets)
		B.ReskinClose(snippets.CloseButton)
		reskinChildButtons(snippets)
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
	for _, child in pairs {frame:GetChildren()} do
		if child:GetFrameStrata() == "FULLSCREEN" and child.PixelSnapDisabled and child.backdropInfo then
			B.StripTextures(child)
			B.SetBD(child)

			for _, child2 in pairs {child:GetChildren()} do
				if child2:GetObjectType() == "EditBox" then
					B.ReskinInput(child2, 18)
				end
			end
			break
		end
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

	local profilingWindow = WeakAuras.RealTimeProfilingWindow
	if profilingWindow then
		hooksecurefunc(profilingWindow, "Init", SkinProfilingWindow)
	end

	if WeakAuras.PrintProfile then
		hooksecurefunc(WeakAuras, "PrintProfile", SkinPrintProfile)
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

local function TalentButton_Red(self)
	self.bg:SetBackdropBorderColor(1, 0, 0)
end

local function TalentButton_Clear(self)
	self.bg:SetBackdropBorderColor(0, 0, 0)
end

function S:WeakAurasMiniTalent(widget)
	for _, button in pairs(widget.buttons) do
		button:SetNormalTexture(0)
		button.bg = B.ReskinIcon(button:GetNormalTexture())
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.cover:SetTexture("")
		hooksecurefunc(button, "Yellow", TalentButton_Clear)
		hooksecurefunc(button, "Red", TalentButton_Red)
		hooksecurefunc(button, "Clear", TalentButton_Clear)
	end
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

function S:WeakAurasTreeGroup(widget)
	S:Ace3_Frame(widget)
	widget.treeframe:GetChildren():HideBackdrop()
end

S:RegisterSkin("WeakAuras", S.WeakAuras)
S:RegisterSkin("WeakAurasOptions", S.WeakAurasOptions)
S:RegisterSkin("WeakAurasTemplates", S.WeakAurasTemplates)
S:RegisterAceGUIWidget("WeakAurasDisplayButton")
S:RegisterAceGUIWidget("WeakAurasNewButton")
S:RegisterAceGUIWidget("WeakAurasPendingUpdateButton")
S:RegisterAceGUIWidget("WeakAurasMultiLineEditBox")
S:RegisterAceGUIWidget("WeakAurasLoadedHeaderButton")
S:RegisterAceGUIWidget("WeakAurasIconButton")
S:RegisterAceGUIWidget("WeakAurasTextureButton")
S:RegisterAceGUIWidget("WeakAurasMiniTalent")
S:RegisterAceGUIWidget("WeakAurasSpinBox")
S:RegisterAceGUIContainer("WeakAurasTreeGroup")