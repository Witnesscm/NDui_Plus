local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleRewards(button)
	for index = 1, 4 do
		local reward = button.Rewards["Reward"..index]
		if reward then
			reward.bg = B.ReskinIcon(reward.Icon)
			B.ReskinIconBorder(reward.IconBorder)
		end
	end
end

local function HandleOptionDropDown(option)
	B.Reskin(option.Dropdown)
	B.Reskin(option.DecrementButton)
	B.Reskin(option.IncrementButton)
end

local function ReskinCategory(category)
	B.StripTextures(category)
	B.Reskin(category)

	for _, setting in ipairs(category.settings) do

		if setting.Container and setting.isSpecial then
			HandleOptionDropDown(setting.Container)
		elseif setting.Dropdown then
			B.ReskinDropDown(setting.Dropdown)
		end

		if setting.Slider then
			B.ReskinSlider(setting.Slider)
		end

		if setting.TextBox then
			B.ReskinInput(setting.TextBox)
		end

		if setting.Button then
			B.Reskin(setting.Button)
		end

		if setting.CheckBox then
			B.ReskinCheck(setting.CheckBox)
		end

		if setting.ResetButton then
			B.Reskin(setting.ResetButton)
		end

		if setting.Picker then
			B.Reskin(setting.Picker)
			setting.Picker.Color:SetAllPoints(setting.Picker.__bg)
		end
	end
end

function S:WorldQuestTab()
	if not S.db["WorldQuestTab"] then return end

	local frame = _G.WQT_WorldQuestFrame
	if not frame then return end

	S:Proxy("ReskinFilterButton", frame.FilterButton)
	S:Proxy("ReskinDropDown", frame.SortDropdown)

	local ScrollFrame = frame.ScrollFrame
	if ScrollFrame then
		if ScrollFrame.Background then
			ScrollFrame.Background:Hide()
		end
		S:Proxy("StripTextures", ScrollFrame.BorderFrame)
		S:Proxy("ReskinTrimScroll", ScrollFrame.ScrollBar)
	end

	local Blocker = frame.Blocker
	if Blocker then
		B.StripTextures(Blocker)
		Blocker.CloseButton:Hide()
		S:Proxy("StripTextures", Blocker.DetailFrame)
		S:Proxy("StripTextures", Blocker.BorderFrame)
	end

	for _, key in ipairs({"WQT_TabNormal", "WQT_TabWorld"}) do
		local tab = _G[key]
		B.StripTextures(tab, 2)
		B.Reskin(tab)
		tab:SetSize(33, 30)

		local icon = tab.Icon
		icon:ClearAllPoints()
		icon:SetPoint("CENTER")

		tab.Selected = tab:CreateTexture(nil, "ARTWORK")
		tab.Selected:SetTexture(DB.bdTex)
		tab.Selected:SetVertexColor(DB.r, DB.g, DB.b, .25)
		tab.Selected:SetInside()
	end

	hooksecurefunc(frame, "SelectTab", function(self, tab)
		_G.WQT_TabNormal.Selected:SetShown(not self:IsShown())
		_G.WQT_TabWorld.Selected:SetShown(self:IsShown())
	end)

	if _G.WQT_ListButtonMixin then
		hooksecurefunc(_G.WQT_ListButtonMixin, "OnLoad", function(self)
			HandleRewards(self)

			local Faction = self.Faction
			Faction.Ring:Hide()

			local Title = self.Title
			Title:ClearAllPoints()
			Title:SetPoint("BOTTOMLEFT", Faction, "RIGHT", 0, 0)

			local Time = self.Time
			Time:ClearAllPoints()
			Time:SetPoint("TOPLEFT", Faction, "RIGHT", 5, 0)

			local Highlight = self.Highlight
			B.StripTextures(Highlight)
			Highlight.HL = Highlight:CreateTexture(nil, "ARTWORK")
			Highlight.HL:SetTexture(DB.bdTex)
			Highlight.HL:SetVertexColor(DB.r, DB.g, DB.b, .25)
			Highlight.HL:SetInside()
		end)
	end

	local SettingsFrame = _G.WQT_SettingsFrame
	if SettingsFrame then
		S:Proxy("ReskinTrimScroll", SettingsFrame.ScrollFrame and SettingsFrame.ScrollFrame.ScrollBar)

		P:Delay(1, function()
			for _, category in ipairs(SettingsFrame.categories) do
				ReskinCategory(category)

				for _, subCategory in ipairs(category.subCategories) do
					ReskinCategory(subCategory)
				end
			end
		end)
	end

	if _G.WQT_SettingsQuestListPreview then
		HandleRewards(_G.WQT_SettingsQuestListPreview.Preview)
	end

	if _G.WQT_VersionFrame then
		S:Proxy("ReskinTrimScroll", _G.WQT_VersionFrame.ScrollBar)
	end

	local ADDT = LibStub("AddonDropDownTemplates-2.0", true)
	if ADDT then
		local origGetFrame = ADDT.GetFrame
		ADDT.GetFrame = function(...)
			local f = origGetFrame(...)
			B.StripTextures(f)
			P.ReskinTooltip(f)
			return f
		end
	end
end

S:RegisterSkin("WorldQuestTab", S.WorldQuestTab)