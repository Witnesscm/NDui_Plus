local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local r, g, b = DB.r, DB.g, DB.b
local isCriteriaProgressBar = 0x00000001

local function SetupButtonHighlight(button, bg)
	if button.Highlight then
		B.StripTextures(button.Highlight)
	end
	button:SetHighlightTexture(DB.bdTex)
	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(r, g, b, .25)
	hl:SetInside(bg)
end

local function SkinSearchResults(button)
	if not button.styled then
		B.StripTextures(button, 2)
		B.ReskinIcon(button.Icon)
		local bg = B.CreateBDFrame(button, .25)
		bg:SetInside()
		SetupButtonHighlight(button, bg)

		button.styled = true
	end
end

local function updateAchievementBorder(button)
	if not button.bg then return end

	local achievement = button.Achievement
	local state = achievement and achievement.TemporaryObtainable and achievement.TemporaryObtainable.Obtainable()
	if state and (state == false or state == "Past" or state == "Future") then
		button.bg:SetBackdropBorderColor(.33, 0, 0)
	elseif state and state == "Current" then
		button.bg:SetBackdropBorderColor(0, .33, 0)
	else
		button.bg:SetBackdropBorderColor(0, 0, 0)
	end

	if button.DateCompleted:IsShown() then
		if button.accountWide then
			button.Header:SetTextColor(0, .6, 1)
		else
			button.Header:SetTextColor(.9, .9, .9)
		end
	else
		if button.accountWide then
			button.Header:SetTextColor(0, .3, .5)
		else
			button.Header:SetTextColor(.65, .65, .65)
		end
	end
end

local function SkinAchivementButton(button)
	if not button.bg then
		B.StripTextures(button, true)
		button.Background:SetAlpha(0)
		button.Highlight:SetAlpha(0)
		button.Icon.Border:Hide()
		button.Description:SetTextColor(.9, .9, .9)
		button.Description.SetTextColor = B.Dummy

		button.bg = B.CreateBDFrame(button, .25)
		button.bg:SetPoint("TOPLEFT", 1, -1)
		button.bg:SetPoint("BOTTOMRIGHT", 0, 2)
		B.ReskinIcon(button.Icon.Texture)

		B.ReskinCheck(button.Tracked)
		button.Tracked:SetSize(20, 20)
		button.Check:SetAlpha(0)

		hooksecurefunc(button, "SetAchievement", updateAchievementBorder)
	end
end

local function SkinAchivementButtonLight(button)
	if not button.bg then
		B.StripTextures(button, true)
		button.Highlight:SetAlpha(0)
		button.Description:SetTextColor(.9, .9, .9)
		button.Description.SetTextColor = B.Dummy
		button.Icon.Border:Hide()
		B.ReskinIcon(button.Icon.Texture)

		button.bg = B.CreateBDFrame(button, .25)
		button.bg:SetPoint("TOPLEFT", 2, -1)
		button.bg:SetPoint("BOTTOMRIGHT", -2, 1)

		hooksecurefunc(button, "SetAchievement", updateAchievementBorder)
		if button.Achievement then button:SetAchievement(button.Achievement) end
	end
end

local function SkinCategory(button)
	if not button.styled then
		B.StripTextures(button)
		local bg = B.CreateBDFrame(button, .25)
		bg:SetPoint("TOPLEFT", 0, -1)
		bg:SetPoint("BOTTOMRIGHT")
		SetupButtonHighlight(button, bg)

		button.styled = true
	end
end

local function SkinCharacterList(button)
	if not button.styled then
		for _, key in ipairs({"HeaderTooltip", "EarnedByAchievementTooltip", "IgnoreCharacter", "MostProgressAchievementTooltip"}) do
			local check = button[key]
			if check then
				B.ReskinCheck(check)
			end
		end

		button.styled = true
	end
end

local function reskinStatusBar(self, isTip)
	B.StripTextures(self)
	self.bg = B.CreateBDFrame(self.Background, .25)
	self.bg:SetPoint("BOTTOMRIGHT", self.Background, "BOTTOMRIGHT", 2*C.mult, -C.mult)

	for i, tex in ipairs(self.Fill) do
		tex:SetTexture(DB.bdTex)
		tex.SetVertexColor = B.Dummy

		if i == 1 then
			tex:SetGradient("VERTICAL", CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
		elseif i ==2 then
			tex:SetGradient("VERTICAL", CreateColor(.4, 0, 0, 1), CreateColor(.6, 0, 0, 1))
		end
	end

	if not isTip then
		self.OffsetY = 8
	end

	if self.Button then
		B.StripTextures(self.Button)
	end
end

local function SkinAlertFrame(self)
	if not self.styled then
		self.Background:SetTexture("")
		self.bg = B.SetBD(self)
		self.bg:SetPoint("TOPLEFT", 0, -7)
		self.bg:SetPoint("BOTTOMRIGHT", 0, 8)
		B.ReskinIcon(self.Icon.Texture)
		self.Icon.Overlay:SetTexture("")
		B.SetFontSize(self.Unlocked, 13)

		self.styled = true
	end
end

local function SkinTextFrame(self)
	if not self.styled then
		B.ReskinPortraitFrame(self)
		S:Proxy("Reskin", self.Button1)

		self.styled = true
	end
end

local function SkinAchievementFrame()
	for i = 4, _G.AchievementFrame.numTabs do
		local tab = _G["AchievementFrameTab"..i]
		if tab and not tab.bg then
			B.ReskinTab(tab)
		end
	end

	local FilterButton = _G.KrowiAF_AchievementFrameFilterButton
	B.ReskinFilterButton(FilterButton)
	FilterButton:SetSize(116, 20)
	FilterButton:ClearAllPoints()
	FilterButton:SetPoint("TOPLEFT", 142, -2)
	if _G.AchievementFrameHeaderLeftDDLInset then _G.AchievementFrameHeaderLeftDDLInset:SetAlpha(0) end

	local PrevButton = _G.KrowiAF_AchievementFrameBrowsingHistoryPrevAchievementButton
	local NextButton = _G.KrowiAF_AchievementFrameBrowsingHistoryNextAchievementButton
	B.ReskinArrow(PrevButton, "left")
	B.ReskinArrow(NextButton, "right")
	PrevButton:ClearAllPoints()
	PrevButton:SetPoint("LEFT", FilterButton, "RIGHT", 10, 0)
	NextButton:ClearAllPoints()
	NextButton:SetPoint("LEFT", PrevButton, "RIGHT", 6, 0)

	local CalendarButton = _G.KrowiAF_AchievementFrameCalendarButton
	B.Reskin(CalendarButton)
	CalendarButton:SetSize(24, 24)
	local CalendarFS = CalendarButton:GetFontString()
	B.SetFontSize(CalendarFS, 13)
	CalendarFS:SetTextColor(1, 1, 1)
	CalendarFS:ClearAllPoints()
	CalendarFS:SetPoint("CENTER", 1, -1)
	CalendarButton.Icon = CalendarButton:CreateTexture(nil, "ARTWORK")
	CalendarButton.Icon:SetInside()
	CalendarButton.Icon:SetTexture("Interface\\Calendar\\UI-Calendar-Button")
	CalendarButton.Icon:SetTexCoord(0.11, 0.390625-.11, 2*0.11, 0.78125-2*0.12)

	-- Search Box
	local SearchBox = _G.KrowiAF_SearchBoxFrame
	B.ReskinInput(SearchBox, 20)
	SearchBox:ClearAllPoints()
	SearchBox:SetPoint("TOPLEFT", 580, -2)

	local SearchButton = _G.KrowiAF_SearchOptionsMenuButton
	B.Reskin(SearchButton)
	SearchButton:SetSize(18, 20)
	SearchButton:ClearAllPoints()
	SearchButton:SetPoint("RIGHT", SearchBox, "LEFT", -C.mult, 0)

	local PreviewContainer = _G.KrowiAF_SearchPreviewContainer
	B.StripTextures(PreviewContainer)
	PreviewContainer:ClearAllPoints()
	PreviewContainer:SetPoint("TOPLEFT", AchievementFrame, "TOPRIGHT", 7, -2)
	PreviewContainer.bg = B.SetBD(PreviewContainer)
	PreviewContainer.bg:SetPoint("TOPLEFT", -3, 3)
	PreviewContainer.bg:SetPoint("BOTTOMRIGHT", PreviewContainer.ShowFullSearchResultsButton, 3, -3)

	for _, button in ipairs(PreviewContainer.Buttons) do
		B.StyleSearchButton(button)
	end
	B.StyleSearchButton(PreviewContainer.ShowFullSearchResultsButton)

	local Result = _G.KrowiAF_SearchResultsFrame
	Result:SetPoint("BOTTOMLEFT", AchievementFrame, "BOTTOMRIGHT", 15, -1)
	B.StripTextures(Result)
	Result.bg = B.SetBD(Result)
	Result.bg:SetPoint("TOPLEFT", -10, 0)
	Result.bg:SetPoint("BOTTOMRIGHT")
	B.ReskinClose(Result.closeButton)
	B.ReskinTrimScroll(Result.ScrollBar)
	hooksecurefunc(Result.ScrollBox, "Update", function(self)
		self:ForEachFrame(SkinSearchResults)
	end)

	-- AchievementsObjectives
	local AchievementsObjectives = _G.KrowiAF_AchievementsObjectives
	hooksecurefunc(AchievementsObjectives, "DisplayCriteria", function(self, id)
		local numTextCriteria, numMetas = 0, 0
		local criteria
		local numCriteria = GetAchievementNumCriteria(id)
		for i = 1, numCriteria do
			local _, criteriaType, completed, _, _, _, flags, assetID = GetAchievementCriteriaInfo(id, i)
			local isCriteriaBar = bit.band(flags, isCriteriaProgressBar) == isCriteriaProgressBar
			if criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID then
				numMetas = numMetas + 1
				criteria = self:GetMeta(numMetas)
			elseif not isCriteriaBar then
				numTextCriteria = numTextCriteria + 1
				criteria = self:GetTextCriteria(numTextCriteria)
			end

			local label = criteria and criteria.Label
			if label and self.Completed and completed then
				label:SetTextColor(1, 1, 1)
			end
		end
	end)

	-- AchievementsFrame
	local AchievementsFrame = _G.KrowiAF_AchievementsFrame
	B.StripTextures(AchievementsFrame)
	B.ReskinTrimScroll(AchievementsFrame.ScrollBar)
	hooksecurefunc(AchievementsFrame.ScrollBox, "Update", function(self)
		self:ForEachFrame(SkinAchivementButton)
	end)

	hooksecurefunc(_G.KrowiAF_AchievementsObjectives, "GetProgressBar", function(self, index)
		local bar = _G["KrowiAF_AchievementsObjectivesProgressBar"..index]
		if bar and not bar.styled then
			B.StripTextures(bar)
			bar:SetStatusBarTexture(DB.bdTex)
			B.CreateBDFrame(bar, .25)

			bar.styled = true
		end
	end)

	-- SummaryFrame
	local SummaryFrame = _G.KrowiAF_SummaryFrame
	B.StripTextures(SummaryFrame)
	SummaryFrame:GetChildren():Hide()
	SummaryFrame.Achievements.Header.Texture:SetAlpha(0)
	SummaryFrame.Categories.Header.Texture:SetAlpha(0)
	SummaryFrame.AchievementsFrame.Border:SetAlpha(0)
	B.ReskinTrimScroll(SummaryFrame.AchievementsFrame.ScrollBar)
	hooksecurefunc(SummaryFrame.AchievementsFrame.ScrollBox, "Update", function(self)
		self:ForEachFrame(SkinAchivementButtonLight)
	end)

	reskinStatusBar(SummaryFrame.TotalStatusBar)
	local origGetStatusBar = SummaryFrame.GetStatusBar
	SummaryFrame.GetStatusBar = function(self, ...)
		local statusBar = origGetStatusBar(self, ...)
		if not statusBar.styled then
			reskinStatusBar(statusBar)
			statusBar.styled = true
		end
		return statusBar
	end

	-- CategoriesFrame
	local CategoriesFrame = _G.KrowiAF_CategoriesFrame
	B.StripTextures(CategoriesFrame)
	B.ReskinTrimScroll(CategoriesFrame.ScrollBar)
	hooksecurefunc(CategoriesFrame.ScrollBox, "Update", function(self)
		self:ForEachFrame(SkinCategory)
	end)

	-- Calendar
	local CalendarFrame = _G.KrowiAF_AchievementCalendarFrame
	B.StripTextures(CalendarFrame)
	B.SetBD(CalendarFrame, nil, 9, 0, -7, 1)
	B.ReskinClose(CalendarFrame.CloseButton, CalendarFrame, -14, -4)
	B.ReskinArrow(CalendarFrame.PrevMonthButton, "left")
	B.ReskinArrow(CalendarFrame.NextMonthButton, "right")

	local TodayFrame = CalendarFrame.TodayFrame
	TodayFrame:SetScript("OnUpdate", nil)
	TodayFrame.Glow:Hide()
	TodayFrame.Texture:Hide()
	TodayFrame.bg = B.CreateBDFrame(TodayFrame, 0)
	TodayFrame.bg:SetInside()
	TodayFrame.bg:SetBackdropBorderColor(r, g, b)
	hooksecurefunc(CalendarFrame, "SetToday", function()
		TodayFrame:SetAllPoints()
	end)

	for _, button in ipairs(CalendarFrame.DayButtons) do
		B.StripTextures(button)
		button:SetHighlightTexture(DB.bdTex)
		local bg = B.CreateBDFrame(button, .25)
		bg:SetInside()
		local hl = button:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .25)
		hl:SetInside(bg)
		hl.SetAlpha = B.Dummy
		button.DarkFrame:SetAlpha(.5)

		for _, achievement in ipairs(button.AchievementButtons) do
			B.ReskinIcon(achievement.Texture)
		end
	end

	local CalendarSideFrame = CalendarFrame.SideFrame
	B.SetBD(CalendarSideFrame)
	CalendarSideFrame.Border:SetAlpha(0)
	B.StripTextures(CalendarSideFrame.Header)
	B.ReskinClose(CalendarSideFrame.CloseButton)
	B.ReskinTrimScroll(CalendarSideFrame.AchievementsFrame.ScrollBar)
	hooksecurefunc(CalendarSideFrame.AchievementsFrame.ScrollBox, "Update", function(self)
		self:ForEachFrame(SkinAchivementButtonLight)
	end)

	-- DataManagerFrame
	local DataManagerFrame = _G.KrowiAF_DataManagerFrame
	if DataManagerFrame then
		B.ReskinPortraitFrame(DataManagerFrame)
		S:Proxy("Reskin", DataManagerFrame.Import)
		local CharacterList = DataManagerFrame.CharacterList
		if CharacterList then
			CharacterList.bg = B.CreateBDFrame(CharacterList, .25)
			CharacterList.bg:SetPoint("BOTTOMRIGHT", -2, 0)
			B.StripTextures(CharacterList.ColumnDisplay)

			for header in CharacterList.ColumnDisplay.columnHeaders:EnumerateActive() do
				header:DisableDrawLayer("BACKGROUND")
				header.bg = B.CreateBDFrame(header, .25)
				header.bg:SetPoint("BOTTOMRIGHT", -4, 1)
				local hl = header:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .25)
				hl:SetAllPoints(header.bg)
			end

			hooksecurefunc(CharacterList.ScrollBox, "Update", function(self)
				self:ForEachFrame(SkinCharacterList)
			end)
		end
	end
end

function S:Krowi_AchievementFilter()
	if not S.db["Krowi_AchievementFilter"] then return end

	local GameTooltipProgressBar = _G.Krowi_ProgressBar1
	if GameTooltipProgressBar then
		reskinStatusBar(GameTooltipProgressBar, true)
	end

	-- AlertSystem
	hooksecurefunc("KrowiAF_EventReminderAlertFrame_Small_OnLoad", SkinAlertFrame)
	hooksecurefunc("KrowiAF_EventReminderAlertFrame_Normal_OnLoad", SkinAlertFrame)

	hooksecurefunc(_G.KrowiAF_TextFrameMixin, "OnLoad", SkinTextFrame)

	if IsAddOnLoaded("Blizzard_AchievementUI") then
		SkinAchievementFrame()
	else
		P:AddCallbackForAddon("Blizzard_AchievementUI", function()
			if _G.KrowiAF_AchievementsFrame then
				SkinAchievementFrame()
			else
				P:Delay(.1, SkinAchievementFrame)
			end
		end)
	end
end

S:RegisterSkin("Krowi_AchievementFilter", S.Krowi_AchievementFilter)