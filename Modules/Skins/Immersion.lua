local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local cr, cg, cb = DB.r, DB.g, DB.b

local function updateItemBorder(self)
	if not self.bg then return end

	if self.objectType == "item" then
		local quality = select(4, GetQuestItemInfo(self.type, self:GetID()))
		local color = DB.QualityColors[quality or 1]
		self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	elseif self.objectType == "currency" then
		local name, texture, numItems, quality = GetQuestCurrencyInfo(self.type, self:GetID())
		local currencyID = GetQuestCurrencyID(self.type, self:GetID())
		if name and texture and numItems and quality and currencyID then
			local currencyQuality = select(4, CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numItems, name, texture, quality))
			local color = DB.QualityColors[currencyQuality or 1]
			self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	else
		self.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function reskinItemButton(self)
	if not self.textBg then
		self.Border:Hide()
		self.Mask:Hide()
		self.NameFrame:Hide()
		self.bg = B.ReskinIcon(self.Icon)
		self.textBg = B.CreateBDFrame(self, .25)
		self.textBg:ClearAllPoints()
		self.textBg:SetPoint("TOPLEFT", self.bg, "TOPRIGHT", 2, 0)
		self.textBg:SetPoint("RIGHT", -5, 0)
		self.textBg:SetPoint("BOTTOM", self.bg, "BOTTOM")
	end
end

local function reskinItemButtons(buttons)
	for i = 1, #buttons do
		local button = buttons[i]
		reskinItemButton(button)
		updateItemBorder(button)
	end
end

function S:Immersion()
	if not S.db["Immersion"] then return end

	local ImmersionFrame = _G.ImmersionFrame
	if not ImmersionFrame then return end

	local TalkBox = ImmersionFrame.TalkBox
	B.StripTextures(TalkBox.PortraitFrame)
	B.StripTextures(TalkBox.BackgroundFrame)
	B.StripTextures(TalkBox.Hilite)
	hooksecurefunc(TalkBox.TextFrame.Text, "OnDisplayLineCallback", function()
		TalkBox.TextFrame.SpeechProgress:SetFont(DB.Font[1], 16, DB.Font[3])
	end)

	local hilite = B.CreateBDFrame(TalkBox.Hilite, 0)
	hilite:SetAllPoints(TalkBox)
	hilite:SetBackdropColor(cr, cg, cb, .25)
	hilite:SetBackdropBorderColor(cr, cg, cb, 1)

	local Elements = TalkBox.Elements
	B.StripTextures(Elements)
	B.SetBD(Elements, nil, 0, -10, 0, 0)
	Elements.Content.RewardsFrame.ItemHighlight.Icon:SetAlpha(0)

	local MainFrame = TalkBox.MainFrame
	B.StripTextures(MainFrame)
	B.SetBD(MainFrame)
	B.ReskinClose(MainFrame.CloseButton)
	B.StripTextures(MainFrame.Model)
	local bg = B.CreateBDFrame(MainFrame.Model, 0)
	bg:SetFrameLevel(MainFrame.Model:GetFrameLevel() + 1)

	local Indicator = MainFrame.Indicator
	Indicator:SetScale(1.25)
	Indicator:ClearAllPoints()
	Indicator:SetPoint("RIGHT", MainFrame.CloseButton, "LEFT", -3, 0)

	local TitleButtons = ImmersionFrame.TitleButtons
	hooksecurefunc(TitleButtons, "GetButton", function(self, index)
		local button = self.Buttons[index]
		if button and not button.styled then
			B.StripTextures(button)
			B.Reskin(button)
			button.Overlay:Hide()
			button.Hilite:Hide()

			if index > 1 then
				button:ClearAllPoints()
				button:SetPoint("TOP", self.Buttons[index-1], "BOTTOM", 0, -3)
			end

			button.styled = true
		end
	end)

	hooksecurefunc(ImmersionFrame, "AddQuestInfo", function(self)
		local rewardsFrame = self.TalkBox.Elements.Content.RewardsFrame

		-- Item Rewards
		reskinItemButtons(rewardsFrame.Buttons)

		-- Honor Rewards
		local honorFrame = rewardsFrame.HonorFrame
		if honorFrame then
			reskinItemButton(honorFrame)

			-- Classic honor icon
			local icon = honorFrame.Icon
			icon:SetTexture(format("Interface\\TargetingFrame\\UI-PVP-%s", (DB.MyFaction or "Horde")))
			icon:SetTexCoord(0, .66, 0, .66)
		end

		-- Title Rewards
		local titleFrame = rewardsFrame.TitleFrame
		if titleFrame and not titleFrame.textBg then
			local icon = titleFrame.Icon
			B.StripTextures(titleFrame, 0)
			icon:SetAlpha(1)
			B.ReskinIcon(icon)
			titleFrame.textBg = B.CreateBDFrame(titleFrame, .25)
			titleFrame.textBg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 2, C.mult)
			titleFrame.textBg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 216, -C.mult)
		end

		-- ArtifactXP Rewards
		local artifactXPFrame = rewardsFrame.ArtifactXPFrame
		if artifactXPFrame then
			reskinItemButton(artifactXPFrame)
			artifactXPFrame.Overlay:SetAlpha(0)
		end

		-- Skill Point Rewards
		local skillPointFrame = rewardsFrame.SkillPointFrame
		if skillPointFrame then
			reskinItemButton(skillPointFrame)
		end

		-- Spell Rewards
		local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(GetQuestID()) or {}
		if #spellRewards > 0 then
			for spellReward in rewardsFrame.spellRewardPool:EnumerateActive() do
				if not spellReward.textBg then
					local icon = spellReward.Icon
					local nameFrame = spellReward.NameFrame
					B.ReskinIcon(icon)
					nameFrame:Hide()
					spellReward.textBg = B.CreateBDFrame(nameFrame, .25)
					spellReward.textBg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 2, C.mult)
					spellReward.textBg:SetPoint("BOTTOMRIGHT", nameFrame, "BOTTOMRIGHT", -24, 15)
				end
			end
		end
	end)

	hooksecurefunc(ImmersionFrame, "QUEST_PROGRESS", function(self)
		reskinItemButtons(self.TalkBox.Elements.Progress.Buttons)
	end)

	hooksecurefunc(ImmersionFrame, "ShowItems", function(self)
		for tooltip in self.Inspector.tooltipFramePool:EnumerateActive() do
			if not tooltip.styled then
				tooltip:HideBackdrop()
				local bg = B.SetBD(tooltip)
				bg:SetPoint("TOPLEFT", 0, 0)
				bg:SetPoint("BOTTOMRIGHT", 6, 0)
				tooltip.Icon.Border:SetAlpha(0)
				B.ReskinIcon(tooltip.Icon.Texture)
				tooltip.Hilite:SetOutside(bg, 2, 2)
				tooltip.styled = true
			end
		end
	end)
end

S:RegisterSkin("Immersion", S.Immersion)