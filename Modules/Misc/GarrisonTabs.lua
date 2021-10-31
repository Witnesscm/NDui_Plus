local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local tabs = {}
local datas = {
	{Enum.GarrisonType.Type_9_0, GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, 3675495},
	{Enum.GarrisonType.Type_8_0, GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, 1044517},
	{Enum.GarrisonType.Type_7_0, ORDER_HALL_LANDING_PAGE_TITLE, 1411833},
	{Enum.GarrisonType.Type_6_0, GARRISON_LANDING_PAGE_TITLE, 237381},
}

local function Select_LandingPage(self)
	HideUIPanel(GarrisonLandingPage)
	ShowGarrisonLandingPage(self.pageID)
end

local function GarrisonLandingPage_Update(pageID)
	for _, tab in pairs(tabs) do
		local available = not not (C_Garrison.GetGarrisonInfo(tab.pageID))
		tab:SetEnabled(available)
		tab:GetNormalTexture():SetDesaturated(not available)
		tab:SetChecked(tab.pageID == pageID)
	end
end

function M:GarrisonTabs()
	if IsAddOnLoaded("MissionReports") then return end

	for index, data in pairs(datas) do
		local tab = CreateFrame("CheckButton", nil, GarrisonLandingPage, "SpellBookSkillLineTabTemplate")
		tab:SetNormalTexture(data[3])
		tab:SetFrameStrata("LOW")
		tab:SetScript("OnClick", Select_LandingPage)
		tab:Show()

		if index == 1 then
			tab:SetPoint("TOPLEFT", GarrisonLandingPage, "TOPRIGHT", 2, -25)
		else
			tab:SetPoint("TOP", tabs[index-1], "BOTTOM", 0, -25)
		end

		if C.db["Skins"]["BlizzardSkins"] then
			tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
			tab:GetRegions():Hide()
			tab:SetCheckedTexture(DB.textures.pushed)
			tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			B.CreateBDFrame(tab)
		end

		tab.pageID = data[1]
		tab.tooltip = data[2]
		table.insert(tabs, tab)
	end

	hooksecurefunc("ShowGarrisonLandingPage", GarrisonLandingPage_Update)
end

P:AddCallbackForAddon("Blizzard_GarrisonUI", M.GarrisonTabs)