local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local select, pairs, type = select, pairs, type
local strfind = string.find

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
			local texturePath = region.GetTextureFilePath and region:GetTextureFilePath()
			if texturePath and type(texturePath) == "string" and strfind(texturePath, "Quickslot2") then
				region:SetTexture("")
			end
		end
	end
end

local function SkinProfilingWindow(frame)
	B.StripTextures(frame)
	B.SetBD(frame)

	local statsFrame = frame.statsFrame
	if statsFrame then
		reskinChildButtons(statsFrame)
	end

	local titleFrame = frame.titleFrame
	if titleFrame then
		for _, child in pairs {titleFrame:GetChildren()} do
			if child:GetObjectType() == "Button" then
				local texturePath = child.GetNormalTexture and child:GetNormalTexture():GetTextureFilePath()
				if texturePath and type(texturePath) == "string" then
					if strfind(texturePath, "CollapseButton") then
						B.ReskinArrow(child, "up")
						child:SetSize(16, 16)
						child:ClearAllPoints()
						child:SetPoint("TOPRIGHT", titleFrame, "TOPRIGHT", -20, -2)
						child.SetNormalTexture = B.Dummy
						child.SetPushedTexture = B.Dummy
						child:HookScript("OnClick",function(self)
							if frame.minimized then
								B.SetupArrow(self.__texture, "down")
							else
								B.SetupArrow(self.__texture, "up")
							end
						end)
					elseif strfind(texturePath, "MinimizeButton") then
						B.ReskinClose(child, titleFrame, -2, -2)
					end
				end
			end
		end
	end
end

local function SkinPrintProfile()
	local popupFrame = _G.WADebugEditBox
	if not popupFrame or popupFrame.styled then return end

	local background = popupFrame.Background
	local scrollFrame = popupFrame.ScrollFrame
	if background and scrollFrame then
		B.StripTextures(background)
		B.SetBD(background)
		background:SetPoint("TOPLEFT", scrollFrame, -20, 30)
		background:SetPoint("BOTTOMRIGHT", scrollFrame, 28, -25)

		for _, child in pairs {background:GetChildren()} do
			local numRegions = child:GetNumRegions()
			local numChildren = child:GetNumChildren()
			if numRegions == 3 and numChildren == 1 and child.PixelSnapDisabled then
				B.StripTextures(child)
				local close = child:GetChildren()
				B.ReskinClose(close)
				close:ClearAllPoints()
				close:SetPoint("TOPRIGHT", background, "TOPRIGHT", -6, -6)
			end
		end

		local scrollBar = scrollFrame.ScrollBar
		if scrollBar then
			B.ReskinScroll(scrollBar)
		end
	end

	popupFrame.styled = true
end

local function SkinWeakAurasOptions()
	local frame = _G.WeakAurasOptions
	if not frame or frame.styled then return end

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinInput(frame.filterInput, 18)
	B.Reskin(_G.WASettingsButton)

	-- Minimize, Close Button (Credit: ElvUI_WindTools)
	for _, child in pairs {frame:GetChildren()} do
		local numRegions = child:GetNumRegions()
		local numChildren = child:GetNumChildren()

		if numRegions == 3 and numChildren == 1 and child.PixelSnapDisabled then
			B.StripTextures(child)

			local button = child:GetChildren()
			local texturePath = button.GetNormalTexture and button:GetNormalTexture():GetTextureFilePath()
			if texturePath and type(texturePath) == "string" and strfind(texturePath, "CollapseButton") then
				B.ReskinArrow(button, "up")
				button:SetSize(18, 18)
				button:ClearAllPoints()
				button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -6)
				button.SetNormalTexture = B.Dummy
				button.SetPushedTexture = B.Dummy

				button:HookScript("OnClick",function(self)
					if frame.minimized then
						B.SetupArrow(self.__texture, "down")
					else
						B.SetupArrow(self.__texture, "up")
					end
				end)
			else
				B.ReskinClose(button, frame)
				button:SetSize(18, 18)
			end
		end
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
	}

	for _, key in pairs(childGroups) do
		local group = frame[key]
		if group then
			reskinChildButtons(group.frame)
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

function S:WeakAuras()
	local WeakAuras = _G.WeakAuras
	if not WeakAuras then return end

	-- Remove Aura Border (Credit: ElvUI_WindTools)
	if WeakAuras.RegisterRegionOptions then
		local origRegisterRegionOptions = WeakAuras.RegisterRegionOptions

		WeakAuras.RegisterRegionOptions = function(name, createFunction, icon, displayName, createThumbnail, ...)
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
	if not WeakAuras or not WeakAuras.ShowOptions then return end

	hooksecurefunc(WeakAuras, "ShowOptions", SkinWeakAurasOptions)
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

S:RegisterSkin("WeakAuras", S.WeakAuras)
S:RegisterSkin("WeakAurasOptions", S.WeakAurasOptions)
S:RegisterSkin("WeakAurasTemplates", S.WeakAurasTemplates)