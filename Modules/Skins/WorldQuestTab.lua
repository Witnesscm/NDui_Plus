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
	if not self.styled then
		for _, reward in ipairs(self.rewardFrames) do
			reward.BorderMask:Hide()
			reward.Icon:SetInside()
			reward.bg = B.ReskinIcon(reward.Icon)
			B.ReskinIconBorder(reward.QualityColor)
			reward.AmountBG:SetAlpha(0)
		end

		self.styled = true
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
	P:SecureHook("WQT_RewardDisplayMixin", "UpdateRewards", HandleRewardButton)

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

	local function wrap(func)
		return function(self, ...)
			if not self.styled then
				func(self, ...)
				self.styled = true
			end
		end
	end

	P:SecureHook("WQT_SettingsCategoryMixin", "Init", wrap(HandleSettingsCategory))
	P:SecureHook("WQT_SettingsCheckboxMixin", "Init", wrap(HandleSettingsCheckbox))
	P:SecureHook("WQT_SettingsSliderMixin", "Init", wrap(HandleSettingsSlider))
	P:SecureHook("WQT_SettingsColorMixin", "Init", wrap(HandleSettingsColor))
	P:SecureHook("WQT_SettingsDropDownMixin", "Init", wrap(HandleSettingsDropDown))
	P:SecureHook("WQT_SettingsButtonMixin", "Init", wrap(HandleSettingsButton))
	P:SecureHook("WQT_SettingsConfirmButtonMixin", "Init", wrap(HandleSettingsButton))
	P:SecureHook("WQT_SettingsTextInputMixin", "Init", wrap(HandleSettingsTextInput))

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

function S:WorldMapTabsLib()
	local tabLib = _G.LibStub and _G.LibStub("WorldMapTabsLib-1.0", true)
	if not tabLib then return end

	ReskinTabs(tabLib)
	hooksecurefunc(tabLib, "CreateTab", ReskinTabs)
	hooksecurefunc(tabLib, "AddCustomTab", ReskinTabs)
end

S:RegisterSkin("WorldMapTabsLib")