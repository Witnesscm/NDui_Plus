local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleListButton(self)
	local Highlight = self.Highlight
	B.StripTextures(Highlight)
	Highlight.HL = Highlight:CreateTexture(nil, "ARTWORK")
	Highlight.HL:SetTexture(DB.bdTex)
	Highlight.HL:SetVertexColor(DB.r, DB.g, DB.b, .3)
	Highlight.HL:SetInside()

	local rewardsFrame = self.GetRewardsFrame and self:GetRewardsFrame()
	if rewardsFrame then
		for _, reward in ipairs(rewardsFrame.rewardFrames) do
			reward.BorderMask:Hide()
			reward.Icon:SetInside()
			reward.bg = B.ReskinIcon(reward.Icon)
			B.ReskinIconBorder(reward.QualityColor)
			reward.AmountBG:SetAlpha(0)
		end
	end
end

local function HandleSettingsCategory(self)
	B.StripTextures(self)
	B.Reskin(self)

	if self.Background then
		self.__bg:SetPoint("TOPLEFT", self.Background, "TOPLEFT", 0, 2)
		self.__bg:SetPoint("BOTTOMRIGHT", self.Background, "BOTTOMRIGHT", 0, 0)
	end

	if self.BGRight then
		self.BGRight:Hide()
	end

	if not self.ExpandIcon then
		self.ExpandIcon = self:CreateTexture(nil, "ARTWORK")
		self.ExpandIcon:SetDesaturated(true)
		self.ExpandIcon:SetPoint("LEFT", 15, 0)
	end
end

local function HandleSettingsCheckbox(self)
	S:Proxy("ReskinCheck", self.CheckBox)
end

local function HandleSettingsSlider(self)
	S:Proxy("ReskinStepperSlider", self.SliderWithSteppers)
	S:Proxy("ReskinInput", self.TextBox)
end

local function HandleSettingsColor(self)
	S:Proxy("Reskin", self.Picker)
	local color = self.Picker.Color
	color:SetTexture(130871)
	color:SetInside(self.Picker.__bg)
	S:Proxy("Reskin", self.ResetButton)
end

local function HandleSettingsDropDown(self)
	S:Proxy("ReskinDropDown", self.Dropdown)
end

local function HandleSettingsButton(self)
	S:Proxy("Reskin", self.Button)
end

local function HandleSettingsConfirmButton(self)
	S:Proxy("Reskin", self.Button)
	S:Proxy("Reskin", self.ButtonConfirm)
	S:Proxy("Reskin", self.ButtonDecline)
end

local function HandleSettingsTextInput(self)
	S:Proxy("ReskinInput", self.TextBox)
end

local function HandleSettingsPreview(self)
	self:DisableDrawLayer("BACKGROUND")
	HandleListButton(self.Preview)
end

local function OnAcquiredQuestFrame(self, frame, data, new)
	if not new then return end

	HandleListButton(frame)
end

local skinFuncs = {
	["WQT_SettingCategoryTemplate"] = HandleSettingsCategory,
	["WQT_SettingSubCategoryTemplate"] = HandleSettingsCategory,
	["WQT_SettingCheckboxTemplate"] = HandleSettingsCheckbox,
	["WQT_SettingSliderTemplate"] = HandleSettingsSlider,
	["WQT_SettingColorTemplate"] = HandleSettingsColor,
	["WQT_SettingDropDownTemplate"] = HandleSettingsDropDown,
	["WQT_SettingButtonTemplate"] = HandleSettingsButton,
	["WQT_SettingConfirmButtonTemplate"] = HandleSettingsConfirmButton,
	["WQT_SettingTextInputTemplate"] = HandleSettingsTextInput,
	["WQT_SettingsQuestListPreviewTemplate"] = HandleSettingsPreview,
}

local function OnAcquiredSettingFrame(self, frame, data, new)
	if not new then return end

	local template = data.template
	local func = template and skinFuncs[template]
	if func then
		func(frame)
	end
end

function S:WorldQuestTab()
	if not S.db["WorldQuestTab"] then return end

	local frame = _G.WQT_WorldQuestFrame
	if not frame then return end

	-- WQT_ListContainer
	local ScrollFrame = frame.ScrollFrame
	if ScrollFrame then
		ScrollFrame.Background:Hide()
		S:Proxy("StripTextures", ScrollFrame.BorderFrame)
		S:Proxy("ReskinTrimScroll", ScrollFrame.ScrollBar)

		local TopBar = ScrollFrame.TopBar
		if TopBar then
			S:Proxy("ReskinFilterButton", TopBar.FilterDropdown)
			S:Proxy("ReskinDropDown", TopBar.SortDropdown)
			S:Proxy("ReskinInput", TopBar.SearchBox)
		end

		local questScrollBox = ScrollFrame.GetQuestScrollBox and ScrollFrame:GetQuestScrollBox()
		if questScrollBox then
			questScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, OnAcquiredQuestFrame)
		end
	end

	-- WQT_SettingsFrame
	local SettingsFrame = frame.SettingsFrame
	if SettingsFrame then
		SettingsFrame.Background:Hide()
		S:Proxy("StripTextures", SettingsFrame.BorderFrame)
		S:Proxy("ReskinTrimScroll", SettingsFrame.ScrollBar)

		local settingsScrollBox = SettingsFrame.ScrollBox
		if settingsScrollBox then
			settingsScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, OnAcquiredSettingFrame)
		end
	end

	-- WQT_Container
	local FlightMapContainer = _G.WQT_FlightMapContainer
	if FlightMapContainer then
		B.StripTextures(FlightMapContainer)
		B.SetBD(FlightMapContainer, nil, 6, 0, 0, 0)
		S:Proxy("Reskin", _G.WQT_FlightMapContainerButton)
	end

	local WorldMapContainer = _G.WQT_WorldMapContainer
	if WorldMapContainer then
		B.StripTextures(WorldMapContainer)
		local bg = B.SetBD(WorldMapContainer, nil, 0, 0, 0, 0)
		bg:SetFrameLevel(bg:GetFrameLevel() + 1)
	end

	-- WQT_GameTooltip
	local WQT_GameTooltip = _G.WQT_GameTooltip
	if WQT_GameTooltip then
		P.ReskinTooltip(WQT_GameTooltip)

		local ItemTooltip = WQT_GameTooltip.ItemTooltip
		if ItemTooltip then
			ItemTooltip.Icon:SetTexCoord(unpack(DB.TexCoord))
			ItemTooltip.bg = B.CreateBDFrame(ItemTooltip.Icon, 0)
			B.ReskinIconBorder(ItemTooltip.IconBorder)
		end

		P.ReskinTooltip(_G.WQT_ShoppingTooltip1)
		P.ReskinTooltip(_G.WQT_ShoppingTooltip2)
	end
end

S:RegisterSkin("WorldQuestTab", S.WorldQuestTab)

local function ReskinTabs(lib)
	for _, tab in ipairs(lib.tabs) do
		if not tab.bg then
			B.StripTextures(tab, 2)
			tab.bg = B.SetBD(tab)
			tab.bg:SetInside(nil, 2, 2)
			local hl = tab:CreateTexture(nil, "HIGHLIGHT")
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetInside(tab.bg)

			tab.SelectedTexture:SetDrawLayer("BACKGROUND")
			tab.SelectedTexture:SetColorTexture(DB.r, DB.g, DB.b, .25)
			tab.SelectedTexture:SetInside(tab.bg)
		end
	end
end

function S:LibWorldMapTabs()
	local tabLib = _G.LibStub and _G.LibStub("LibWorldMapTabs", true)
	if not tabLib then return end

	ReskinTabs(tabLib)
	hooksecurefunc(tabLib, "CreateTab", ReskinTabs)
	hooksecurefunc(tabLib, "AddCustomTab", ReskinTabs)
end

S:RegisterSkin("LibWorldMapTabs")
