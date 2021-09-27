local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local ipairs = ipairs

local function Scroll_OnEnter(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	thumb.bg:SetBackdropBorderColor(DB.r, DB.g, DB.b)
end

local function Scroll_OnLeave(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(0, 0, 0, 0)
	thumb.bg:SetBackdropBorderColor(0, 0, 0)
end

local function reskinScroll(self)
	B.StripTextures(self)

	local thumb = self.thumbTexture
	if thumb then
		thumb:SetAlpha(0)
		thumb:SetWidth(16)
		self.thumb = thumb

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetPoint("TOPLEFT", thumb, 2, -2)
		bg:SetPoint("BOTTOMRIGHT", thumb, 2, 4)
		thumb.bg = bg
	end

	self:HookScript("OnEnter", Scroll_OnEnter)
	self:HookScript("OnLeave", Scroll_OnLeave)
end

local function reskinRewards(button)
	for index = 1, 4 do
		local reward = button.Rewards["Reward"..index]
		if reward then
			reward.bg = B.ReskinIcon(reward.Icon)
			B.ReskinIconBorder(reward.IconBorder)

			reward:ClearAllPoints()
			if index == 1 then
				reward:SetPoint("RIGHT", button, "RIGHT", -5, 0)
			else
				reward:SetPoint("RIGHT", button.Rewards["Reward"..(index-1)].icbg, "LEFT", -2, 0)
			end
		end
	end
end

local function reskinCategory(category)
	B.StripTextures(category)
	B.Reskin(category)

	for _, setting in ipairs(category.settings) do
		if setting.DropDown then
			P.ReskinDropDown(setting.DropDown)
			setting.DropDown.Button:SetPoint("RIGHT", -18, -2)
			setting.DropDown.bg:SetPoint("LEFT", 6, 0)
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
			setting.Picker.Color:SetInside(setting.Picker.__Tex, 0, 0)
		end
	end
end

function S:WorldQuestTab()
	if not S.db["WorldQuestTab"] then return end

	WQT_WorldQuestFrame.Background:Hide()
	B.StripTextures(WQT_QuestLogFiller)
	B.StripTextures(WQT_OverlayFrame)
	B.StripTextures(WQT_OverlayFrame.DetailFrame)
	B.StripTextures(WQT_QuestScrollFrame.DetailFrame)

	reskinScroll(WQT_SettingsFrame.ScrollFrame.ScrollBar)
	reskinScroll(WQT_VersionFrame.scrollBar)
	B.ReskinScroll(WQT_QuestScrollFrameScrollBar)
	B.Reskin(WQT_WorldQuestFrameSettingsButton)
	P.ReskinDropDown(WQT_WorldQuestFrameSortButton)
	WQT_WorldQuestFrameSortButton.Button:SetPoint("RIGHT", -10, -2)
	WQT_WorldQuestFrameSortButton.bg:SetPoint("LEFT", 6, 0)
	B.ReskinFilterButton(WQT_WorldQuestFrameFilterButton)
	WQT_OverlayFrame.CloseButton:Hide()
	reskinRewards(WQT_SettingsQuestListPreview.Preview)

	for _, tab in pairs({WQT_TabNormal, WQT_TabWorld}) do
		B.StripTextures(tab, 2)
		B.Reskin(tab)

		local icon = tab.Icon
		icon:ClearAllPoints()
		icon:SetPoint("CENTER")

		tab.HL = tab:CreateTexture(nil, "ARTWORK")
		tab.HL:SetTexture(DB.bdTex)
		tab.HL:SetVertexColor(DB.r, DB.g, DB.b, .25)
		tab.HL:SetInside()
	end

	hooksecurefunc(WQT_WorldQuestFrame, "SelectTab", function(self, tab)
		local id = tab and tab:GetID() or 0
		if (not QuestScrollFrame.Contents:IsShown() and not QuestMapFrame.DetailsFrame:IsShown()) or id == 1 then
			WQT_TabNormal.HL:Show()
			WQT_TabWorld.HL:Hide()
		elseif id == 2 then
			WQT_TabWorld.HL:Show()
			WQT_TabNormal.HL:Hide()
		end
	end)

	for _, button in ipairs(WQT_QuestScrollFrame.buttons) do
		reskinRewards(button)

		local Faction = button.Faction
		Faction.Ring:Hide()

		local Title = button.Title
		Title:ClearAllPoints()
		Title:SetPoint("BOTTOMLEFT", Faction, "RIGHT", 0, 0)

		local Time = button.Time
		Time:ClearAllPoints()
		Time:SetPoint("TOPLEFT", Faction, "RIGHT", 5, 0)

		local Highlight = button.Highlight
		B.StripTextures(Highlight)
		Highlight.HL = Highlight:CreateTexture(nil, "ARTWORK")
		Highlight.HL:SetTexture(DB.bdTex)
		Highlight.HL:SetVertexColor(DB.r, DB.g, DB.b, .25)
		Highlight.HL:SetInside()
	end

	local ADDT = LibStub("AddonDropDownTemplates-2.0", true)
	if ADDT then
		local origGetFrame = ADDT.GetFrame
		ADDT.GetFrame = function(...)
			local frame = origGetFrame(...)
			B.StripTextures(frame)
			P.ReskinTooltip(frame)
			return frame
		end
	end

	local function reskinSettings(event)
		for _, category in ipairs(WQT_SettingsFrame.categories) do
			reskinCategory(category)

			local numSubs = #category.subCategories
			if numSubs > 0 then
				for i = 1, numSubs do
					reskinCategory(category.subCategories[i])
				end
			end
		end

		B:UnregisterEvent(event, reskinSettings)
	end
	B:RegisterEvent("PLAYER_ENTERING_WORLD", reskinSettings)
end

S:RegisterSkin("WorldQuestTab", S.WorldQuestTab)