local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleItemButton(self)
	self.bg = B.ReskinIcon(self.Icon, true)
	B.ReskinIconBorder(self.IconBorder, true)

	if self.bg.__shadow then
		self.bg.__shadow:SetFrameLevel(self:GetFrameLevel())
	end
end

local function ReskinCatalystFrame(frame)
	for _, child in pairs {frame:GetChildren()} do
		if not child.styled then
			local objType = child:GetObjectType()
			if objType == "Frame" and child.Bg then
				B.StripTextures(child)
				local bg = B.SetBD(child)
				bg:SetInside()
				child.styled = true
			elseif objType == "Button" and child.Icon and child.FavoriteStar then
				HandleItemButton(child)
				child.styled = true
			end
		end
	end
end

local function ReskinTooltipFrame(frame)
	for _, child in pairs {frame:GetChildren()} do
		local objType = child:GetObjectType()
		if objType == "Button" and child.Ticksquare and child.Checkmark then
			local Ticksquare = child.Ticksquare
			local Checkmark = child.Checkmark
			local Background = child.Background

			if not child.bg then
				child.bg = B.CreateBDFrame(Ticksquare)
				child.bg:SetAllPoints(Ticksquare)
				Ticksquare:SetTexture("")

				Checkmark:SetAtlas("checkmark-minimal")
				Checkmark:SetVertexColor(DB.r, DB.g, DB.b)
				Checkmark:SetSize(20, 20)
				Checkmark:SetDesaturated(true)
				Checkmark:ClearAllPoints()
				Checkmark:SetPoint("CENTER", Ticksquare)

				Background:SetTexture(DB.bdTex)
				Background:SetVertexColor(DB.r, DB.g, DB.b, .25)
				Background:ClearAllPoints()
				Background:SetPoint("TOPLEFT", -15 + 2*C.mult, 0)
				Background:SetPoint("BOTTOMRIGHT", 15 - 2*C.mult, 0)
			end

			child.bg:SetShown(Ticksquare:IsShown() and Ticksquare:GetAlpha() == 1)
		end
	end
end

local function HandleDungeon(self)
	B.StripTextures(self, 0)
	self.Bg:SetAlpha(1)
	B.CreateBDFrame(self.Bg, 0)

	for _, button in ipairs(self.itemFrames) do
		HandleItemButton(button)
	end

	local button = self.TeleportButton
	if button then
		local icon = button.Icon:GetTexture()
		local noTex = button.NoTeleportTexture:GetTexture()
		B.StripTextures(button)
		button.Icon:SetTexture(icon)
		button.NoTeleportTexture:SetTexture(noTex)
		button.bg = B.ReskinIcon(button.Icon)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button:GetHighlightTexture():SetInside(button.bg)
	end
end

local function ReskinDungeonsFrame(frame)
	if not frame.styled then
		B.StripTextures(frame)

		for _, child in pairs {frame:GetChildren()} do
			local objType = child:GetObjectType()
			if objType == "Button" and child.Icon and child.Text then
				B.ReskinFilterButton(child)
				if child.__texture then
					child.__texture:Hide()
				end
			elseif objType == "Frame" and child.Title and child.itemFrames then
				HandleDungeon(child)
			end
		end

		frame.styled = true
	end
end

local function updateBackdropColor(self, isDisabled)
	if isDisabled then
		self.bg:SetBackdropColor(0, 0, 0, .25)
	else
		self.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	end
end

local function HandleRaid(self)
	self.BgTexture:SetAlpha(0)
	self.iconbg = B.ReskinIcon(self.BossIcon)
	self.bg = B.CreateBDFrame(self, .25)
	self.bg:ClearAllPoints()
	self.bg:SetPoint("TOPLEFT", self.iconbg, "TOPRIGHT", 2, 0)
	self.bg:SetPoint("BOTTOMLEFT", self.iconbg, "BOTTOMRIGHT", 2, 0)
	self.bg:SetPoint("RIGHT")

	for _, button in ipairs(self.itemFrames) do
		HandleItemButton(button)
	end

	updateBackdropColor(self, self.BgTexture:IsDesaturated())
	hooksecurefunc(self, "SetDisabled", updateBackdropColor)
end

local function ReskinRaidTab(frame)
	for _, child in pairs {frame:GetChildren()} do
		local objType = child:GetObjectType()
		if objType == "Frame" and child.Title and child.BossIcon and child.itemFrames then
			HandleRaid(child)
		end
	end
end

local function ReskinRaidsFrame(frame)
	if not frame.styled then
		B.StripTextures(frame)

		for _, child in pairs {frame:GetChildren()} do
			local objType = child:GetObjectType()
			if objType == "Button" and child.Icon and child.Text then
				B.ReskinFilterButton(child)
				if child.__texture then
					child.__texture:Hide()
				end
			end
		end

		for i, tab in ipairs(frame.Tabs) do
			B.ReskinTab(tab)
			B.ResetTabAnchor(tab)

			if i ~= 1 then
				tab:ClearAllPoints()
				tab:SetPoint("TOPLEFT", frame.Tabs[i-1], "TOPRIGHT", -15, 0)
			end

			ReskinRaidTab(tab.Children)
		end

		frame.styled = true
	end
end

function S:KeystoneLoot()
	local frame = _G.KeystoneLootFrame
	if not frame then return end

	B.ReskinPortraitFrame(frame)

	for _, child in pairs {frame:GetChildren()} do
		local texture = child.GetNormalTexture and child:GetNormalTexture()
		local atlas = texture and texture:GetAtlas()
		if atlas and atlas == "RedButton-Exit" then
			B.ReskinClose(child)
			break
		end
	end

	local OptionsButton = frame.OptionsButton
	if OptionsButton then
		OptionsButton:ClearAllPoints()
		OptionsButton:SetPoint("TOPRIGHT", -28, -6)
	end

	local CatalystFrame = frame.CatalystFrame
	if CatalystFrame then
		CatalystFrame:ClearAllPoints()
		CatalystFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, -40)
		CatalystFrame:HookScript("OnShow", ReskinCatalystFrame)
	end

	local TooltipFrame = frame.TooltipFrame
	if TooltipFrame then
		P.ReskinTooltip(TooltipFrame)
		TooltipFrame:HookScript("OnShow", ReskinTooltipFrame)
	end

	for i, tab in ipairs(frame.Tabs) do
		B.ReskinTab(tab)
		B.ResetTabAnchor(tab)

		if i ~= 1 then
			tab:ClearAllPoints()
			tab:SetPoint("TOPLEFT", frame.Tabs[i-1], "TOPRIGHT", -15, 0)
		end

		if tab.id == "dungeons" then
			tab.Children:HookScript("OnShow", ReskinDungeonsFrame)
		elseif tab.id == "raids" then
			tab.Children:HookScript("OnShow", ReskinRaidsFrame)
		end
	end
end

S:RegisterSkin("KeystoneLoot", S.KeystoneLoot)