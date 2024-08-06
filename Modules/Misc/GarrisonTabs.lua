local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")
--------------------------
-- Credit: Mission Report
--------------------------
local tabs = {}

local garrisonData = {
	{Enum.GarrisonType.Type_9_0_Garrison, GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, 3675495},
	{Enum.GarrisonType.Type_8_0_Garrison, GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, 1044517},
	{Enum.GarrisonType.Type_7_0_Garrison, ORDER_HALL_LANDING_PAGE_TITLE, 1411833},
	{Enum.GarrisonType.Type_6_0_Garrison, GARRISON_LANDING_PAGE_TITLE, 237381},
}

local function ToggleLandingPage(self)
	if self.pageID ~= self.__owner.garrTypeID then
		HideUIPanel(self.__owner)
		ShowGarrisonLandingPage(self.pageID)
	else
		self:SetChecked(true)
	end
end

local function GarrisonLandingPage_UpdateTabs(self)
	for _, tab in pairs(tabs) do
		local available = C_Garrison.HasGarrison(tab.pageID)
		tab:SetEnabled(available)
		tab:GetNormalTexture():SetDesaturated(not available)
		tab:SetChecked(tab.pageID == self.garrTypeID)
	end
end

local function GarrisonTab_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltip)
	GameTooltip:Show()
end

function M:GarrisonTabs_Create()
	for index, data in pairs(garrisonData) do
		local tab = CreateFrame("CheckButton", nil, _G.GarrisonLandingPage)
		tab:SetSize(32, 32)
		tab.__owner = _G.GarrisonLandingPage
		tab:SetNormalTexture(data[3])
		tab:SetScript("OnClick", ToggleLandingPage)
		tab:SetScript("OnEnter", GarrisonTab_OnEnter)
		tab:SetScript("OnLeave", B.HideTooltip)
		tab:Show()

		if index == 1 then
			tab:SetPoint("TOPLEFT", _G.GarrisonLandingPage, "TOPRIGHT", 2, -25)
		else
			tab:SetPoint("TOP", tabs[index-1], "BOTTOM", 0, -25)
		end

		if C.db["Skins"]["BlizzardSkins"] then
			tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
			tab:SetCheckedTexture(DB.pushedTex)
			tab:SetHighlightTexture(DB.bdTex)
			tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			B.CreateBDFrame(tab)
		end

		tab.pageID = data[1]
		tab.tooltip = data[2]
		table.insert(tabs, tab)
	end

	hooksecurefunc(_G.GarrisonLandingPage, "UpdateUIToGarrisonType", GarrisonLandingPage_UpdateTabs)
end

-- fix error and some incorrect wigdets when toggle old expansion page
function M:FixOldExpansionPage()
	hooksecurefunc(_G.GarrisonLandingPage, "UpdateUIToGarrisonType", function(self)
		self.Report.Sections:SetShown(self.garrTypeID == Enum.GarrisonType.Type_9_0_Garrison)

		if self.garrTypeID ~= Enum.GarrisonType.Type_6_0_Garrison and GarrisonThreatCountersFrame:IsShown() then
			GarrisonThreatCountersFrame:Hide()
		end
	end)

	local done
	hooksecurefunc(_G.GarrisonLandingPage.FollowerList, "Setup", function(self)
		if done then return end

		local buttons = self.listScroll and self.listScroll.buttons
		if buttons then
			for _, button in ipairs(buttons) do
				local follower = button.Follower
				if follower and not follower.DownArrow then
					local downArrow = follower:CreateTexture(nil, "ARTWORK")
					downArrow:SetTexture("Interface\\Buttons\\SquareButtonTextures")
					downArrow:SetSize(13, 13)
					downArrow:SetPoint("TOPRIGHT", -10, -38)
					downArrow:SetTexCoord(.45312500, .64062500, .01562500, .20312500)
					downArrow:SetAlpha(0)
					follower.DownArrow = downArrow
				end
			end

			done = true
		end
	end)

	hooksecurefunc(_G.GarrisonLandingPage.FollowerList, "UpdateFollowers", function(self)
		if not self.followerTab then return end

		if not GarrisonFollowerOptions[self.followerType].showNumFollowers then
			self.followerTab.NumFollowers:SetText("")
		end
	end)

	hooksecurefunc(_G.GarrisonLandingPage.FollowerTab, "ShowFollower", function(self)
		local isAutoCombatant = self:GetParent():GetFollowerList().followerType == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower
		if not isAutoCombatant then
			if self.CovenantFollowerPortraitFrame then
				self.CovenantFollowerPortraitFrame:Hide()
			end
			self.Class:Show()
			self.autoCombatStatsPool:ReleaseAll()
			self.autoSpellPool:ReleaseAll()
			self.AbilitiesFrame:Layout()
		end
	end)

	local FleetTab = _G.GarrisonLandingPage.FleetTab
	if FleetTab then
		FleetTab:SetScript("OnEnter", function(self)
			if self.isDisabled then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(GARRISON_SHIPYARD_NO_SHIPS_TOOLTIP, nil, nil, nil, nil, true)
				GameTooltip:Show()
			else
				self.LeftHighlight:Show()
				self.MiddleHighlight:Show()
				self.RightHighlight:Show()
			end
		end)

		FleetTab:SetScript("OnLeave", function(self)
			self.LeftHighlight:Hide()
			self.MiddleHighlight:Hide()
			self.RightHighlight:Hide()
			GameTooltip_Hide(self)
		end)
	end
end

function M:GarrisonTabs()
	if not M.db["GarrisonTabs"] then return end

	M:GarrisonTabs_Create()
	M:FixOldExpansionPage()
end

P:AddCallbackForAddon("Blizzard_GarrisonUI", M.GarrisonTabs)