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
end

local function HandleRewardButton(self)
	for _, reward in ipairs(self.rewardFrames) do
		reward.BorderMask:Hide()
		reward.Icon:SetInside()
		reward.bg = B.ReskinIcon(reward.Icon)
		B.ReskinIconBorder(reward.QualityColor)
		reward.AmountBG:SetAlpha(0)
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
	self.Picker.Color:SetAllPoints(self.Picker.__bg)
	S:Proxy("Reskin", self.ResetButton)
end

local function HandleSettingsDropDown(self)
	S:Proxy("ReskinDropDown", self.Dropdown)
end

local function HandleSettingsButton(self)
	S:Proxy("Reskin", self.Button)
end

local function HandleSettingsTextInput(self)
	S:Proxy("ReskinInput", self.TextBox)
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
		S:Proxy("ReskinFilterButton", ScrollFrame.FilterDropdown)
		S:Proxy("ReskinDropDown", ScrollFrame.SortDropdown)
		S:Proxy("ReskinTrimScroll", ScrollFrame.ScrollBar)
	end

	P:SecureHook("WQT_ListButtonMixin", "OnLoad", HandleListButton)
	P:SecureHook("WQT_RewardDisplayMixin", "OnLoad", HandleRewardButton)

	-- WQT_WhatsNewFrame
	local WhatsNewFrame = frame.WhatsNewFrame
	if WhatsNewFrame then
		WhatsNewFrame.Background:Hide()
		S:Proxy("StripTextures", WhatsNewFrame.BorderFrame)
		S:Proxy("ReskinTrimScroll", WhatsNewFrame.ScrollBar)
	end

	-- WQT_SettingsFrame
	local SettingsFrame = frame.SettingsFrame
	if SettingsFrame then
		SettingsFrame.Background:Hide()
		S:Proxy("StripTextures", SettingsFrame.BorderFrame)
		S:Proxy("ReskinTrimScroll", SettingsFrame.ScrollBar)
	end

	local SettingsPreview = _G.WQT_SettingsQuestListPreview and _G.WQT_SettingsQuestListPreview.Preview
	if SettingsPreview and SettingsPreview.Rewards then
		HandleRewardButton(SettingsPreview.Rewards)
	end

	P:SecureHook("WQT_SettingsCategoryMixin", "Init", HandleSettingsCategory)
	P:SecureHook("WQT_SettingsCheckboxMixin", "Init", HandleSettingsCheckbox)
	P:SecureHook("WQT_SettingsSliderMixin", "Init", HandleSettingsSlider)
	P:SecureHook("WQT_SettingsColorMixin", "Init", HandleSettingsColor)
	P:SecureHook("WQT_SettingsDropDownMixin", "Init", HandleSettingsDropDown)
	P:SecureHook("WQT_SettingsButtonMixin", "Init", HandleSettingsButton)
	P:SecureHook("WQT_SettingsConfirmButtonMixin", "Init", HandleSettingsButton)
	P:SecureHook("WQT_SettingsTextInputMixin", "Init", HandleSettingsTextInput)

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
end

S:RegisterSkin("WorldQuestTab", S.WorldQuestTab, true)