local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)
local G = P:RegisterModule("GUI")

local guiTab, guiPage, gui = {}, {}

G.TextureList = {}

G.Points = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "TOP", "BOTTOM", "LEFT", "RIGHT"}

G.Quality = {
	[1] = ITEM_QUALITY_COLORS[1].hex .. ITEM_QUALITY1_DESC .. "|r",
	[2] = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC .. "|r",
	[3] = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC .. "|r",
	[4] = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC .. "|r",
}

local function setupChangelog()
	G:SetupChangelog(gui)
end

local function setupABFader()
	G:SetupABFader(guiPage[1])
end

local function setupMageBar()
	G:SetupMageBar(guiPage[1])
end

local function setupUFsFader()
	G:SetupUFsFader(guiPage[3])
end

local function setupChatAutoShow()
	G:SetupChatAutoShow(guiPage[4])
end

local function updateABFaderState()
	local AB = P:GetModule("ActionBar")
	if not AB.fadeParent then return end

	AB:UpdateFaderState()
	AB.fadeParent:SetAlpha(AB.db["Alpha"])
end

local function toggleMageBar()
	P:GetModule("ActionBar"):MageBar_Toggle()
end

local function updateMageBar()
	P:GetModule("ActionBar"):MageBar_Update()
end

local function updateMageBarSize()
	P:GetModule("ActionBar"):MageBar_UpdateSize()
end

local function openKeyBindingFrame()
	_G.GameMenuButtonKeybindings:Click()

	for _, button in ipairs(_G.KeyBindingFrame.categoryList.buttons) do
		if button.text:GetText() == ADDONS then
			button:Click()
			break
		end
	end
end

local function updateUFsFader()
	P:GetModule("UnitFrames"):UpdateUFsFader()
end

local function updateTankHeaders()
	P:GetModule("UnitFrames"):UpdateTankHeaders()
end

local function updateTankSize()
	P:GetModule("UnitFrames"):UpdateTankSize()
end

local function updateChatAutoShow()
	P:GetModule("Chat"):UpdateAutoShow()
end

local function updateChatAutoHide()
	P:GetModule("Chat"):UpdateAutoHide()
end

local function updateToggleVisible()
	P:GetModule("Skins"):UpdateToggleVisible()
end

local function updateArrowVisible()
	P:GetModule("Skins"):UpdateArrowVisible()
end

local function clearInspectCache()
	P:GetModule("Tooltip"):ClearInspectCache()
end

local function hideLootRoll()
	if _G.NDuiPlus_LootRoll then _G.NDuiPlus_LootRoll:Hide() end
end

local function updateLootRoll()
	P:GetModule("LootRoll"):UpdateLootRollTest()
end

local function updateAFKMode()
	P:GetModule("AFK"):Toggle()
end

local function updateFlightMapScale()
	P:GetModule("Misc"):UpdateFlightMapScale()
end

local function setupTexStyle()
	NDuiPlusDB["TexStyle"]["Index"] = 0

	for i, v in ipairs(P.TextureTable) do
		tinsert(G.TextureList, v.name)
		if v.name == NDuiPlusDB["TexStyle"]["Texture"] then
			NDuiPlusDB["TexStyle"]["Index"] = i
		end
	end
end

local function toggleTexStyle()
	NDuiPlusDB["TexStyle"]["Texture"] = G.TextureList[NDuiPlusDB["TexStyle"]["Index"]]
end

local function AddTextureToOption(parent, index)
	local tex = parent[index]:CreateTexture()
	tex:SetInside(nil, 4, 4)
	tex:SetTexture(P.TextureTable[index].texture)
	tex:SetVertexColor(DB.r, DB.g, DB.b)
end

-- Config
local HeaderTag = "|cff00cc4c"
local NewTag = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0|t"

G.TabList = {
	L["Actionbar"],
	L["Bags"],
	L["UnitFrames"],
	L["Chat"],
	L["Skins"],
	NewTag..L["Tooltip"],
	L["Misc"],
}

G.OptionList = { -- type, key, value, name, horizon, data, callback, tooltip, scripts
	[1] = {
		{1, "ActionBar", "FinisherGlow", HeaderTag..L["FinisherGlow"], nil, nil, nil, L["FinisherGlowTip"]},
		{},
		{1, "ActionBar", "GlobalFade", HeaderTag..L["GlobalFadeEnable"], nil, setupABFader},
		{1, "ActionBar", "Bar1", L["Bar"].."1*", nil, nil, updateABFaderState},
		{1, "ActionBar", "Bar2", L["Bar"].."2*", true, nil, updateABFaderState},
		{1, "ActionBar", "Bar3", L["Bar"].."3*", nil, nil, updateABFaderState},
		{1, "ActionBar", "Bar4", L["Bar"].."4*", true, nil, updateABFaderState},
		{1, "ActionBar", "Bar5", L["Bar"].."5*", nil, nil, updateABFaderState},
		{1, "ActionBar", "Bar6", L["Bar"].."6*", true, nil, updateABFaderState},
		{1, "ActionBar", "Bar7", L["Bar"].."7*", nil, nil, updateABFaderState},
		{1, "ActionBar", "Bar8", L["Bar"].."8*", true, nil, updateABFaderState},
		{1, "ActionBar", "PetBar", L["PetBar"].."*", nil, nil, updateABFaderState},
		{1, "ActionBar", "StanceBar", L["StanceBar"].."*", true, nil, updateABFaderState},
		{1, "ActionBar", "AspectBar", L["AspectBar"].."*", nil, nil, updateABFaderState},
		{1, "ActionBar", "MageBarFade", L["MageBar"].."*", true, nil, updateABFaderState},
		{},
		{1, "ActionBar", "MageBar", HeaderTag..L["MageBar"].."*", nil, setupMageBar, toggleMageBar, L["MageBarTip"]},
		{1, "ActionBar", "MageBarVertical", L["MageBarVertical"].."*", nil, nil, updateMageBar},
		{3, "ActionBar", "MageBarSize", L["MageBarSize"].."*", true, {24, 60, 1}, updateMageBarSize},
	},
	[2] = {
		{1, "Bags", "OfflineBag", HeaderTag..L["OfflineBagEnable"], nil, nil, nil, L["OfflineBagTip"]},
		{6, nil, nil, L["Set KeyBinding"], true, openKeyBindingFrame},
		{},
		{3, "Bags", "BagsWidth", L["BagsWidth"], nil, {10, 20, 1}},
		{3, "Bags", "IconSize", L["BagsIconSize"], true, {30, 42, 1}},
	},
	[3] = {
		{1, "UnitFrames", "Fader", HeaderTag..L["UnitFramesFader"].."*", nil, setupUFsFader, updateUFsFader, L["UnitFramesFaderTip"]},
		{},
		{1, "C:UnitFrames", "TankFrame", HeaderTag..L["TankFrame"]},
		{1, "C:UnitFrames", "TankTarget", L["Target Frame"]},
		{4, "C:UnitFrames", "TankFilter", FILTER.."*", true, {TANK, MAINTANK}, updateTankHeaders},
		{3, "C:UnitFrames", "TankWidth", L["Frame Width"].."*", nil, {60, 200, 1}, updateTankSize},
		{4, "C:UnitFrames", "TankDirec", L["Growth Direction"], true, {L["GO_DOWN"], L["GO_UP"], L["GO_RIGHT"], L["GO_LEFT"]}},
		{3, "C:UnitFrames", "TankHeight", L["Frame Height"].."*", nil, {25, 60, 1}, updateTankSize},
		{3, "C:UnitFrames", "TankPowerHeight", L["Power Height"].."*", true, {0, 20, 1}, updateTankSize},
	},
	[4] = {
		{1, "Chat", "Emote", L["ChatEmote"], nil, nil, nil, L["ChatEmoteTip"]},
		{1, "Chat", "ClassColor", L["ChatClassColor"], true, nil, nil, L["ChatClassColorTip"]},
		{1, "Chat", "RaidIndex", L["ChatRaidIndex"].."*", nil, nil, nil, L["ChatRaidIndexTip"]},
		{1, "Chat", "Role", L["ChatRole"].."*", true, nil, nil, L["ChatRoleTip"]},
		{1, "Chat", "Icon", L["ChatLinkIcon"].."*"},
		{},
		{1, "Chat", "ChatHide", HeaderTag..L["ChatHide"], nil, nil, nil, L["ChatHideTip"]},
		{1, "Chat", "AutoShow", L["AutoShow"].."*", nil, setupChatAutoShow, updateChatAutoShow, L["AutoShowTip"]},
		{1, "Chat", "AutoHide", L["AutoHide"].."*", nil, nil, updateChatAutoHide, L["AutoHideTip"]},
		{3, "Chat", "AutoHideTime", L["AutoHideTime"].."*", true, {5, 60, 1}},
	},
	[5] = {
		{1, "TexStyle", "Enable", HeaderTag..L["ReplaceTexture"], nil, nil, nil, L["ReplaceTextureTip"]},
		{4, "TexStyle", "Index", L["Texture Style"], nil, {}, toggleTexStyle},
		{L["Addon Skin"]},
		{},
		{1, "Skins", "HideToggle", L["HideToggle"].."*", nil, nil, updateToggleVisible},
		{1, "Skins", "CategoryArrow", L["CategoryArrow"].."*", true, nil, updateArrowVisible},
	},
	[6] = {
		{1, "Tooltip", "SpecLevel", NewTag..HeaderTag..L["SpecLevel"].."*"},
		{1, "Tooltip", "TalentPoints", L["TalentPoints"].."*", true, nil, clearInspectCache},
		{1, "Tooltip", "TalentIcon", L["TalentIcon"].."*", nil, nil, clearInspectCache},
	},
	[7] = {
		{1, "Loot", "Enable", HeaderTag..L["LootEnhancedEnable"], nil, nil, nil, L["LootEnhancedTip"]},
		{1, "Loot", "Announce", L["LootAnnounceButton"]},
		{1, "Loot", "AnnounceTitle", L["Announce Target Name"].."*"},
		{4, "Loot", "AnnounceRarity", L["Rarity Threshold"].."*", true, G.Quality},
		{},
		{1, "LootRoll", "Enable", HeaderTag..L["LootRoll"], nil, nil, nil, L["LootRollTip"], {OnHide = hideLootRoll}},
		{1, "LootRoll", "ItemLevel", L["Item Level"].."*", nil, nil, updateLootRoll},
		{1, "LootRoll", "ItemQuality", L["Item Quality"].."*", true, nil, updateLootRoll},
		{4, "LootRoll", "Style", L["Style"], false, {L["Style 1"], L["Style 2"]}, updateLootRoll},
		{4, "LootRoll", "Direction", L["Growth Direction"], true, {L["Up"], L["Down"]}},
		{3, "LootRoll", "Width", L["Frame Width"], false, {200, 500, 1}, updateLootRoll},
		{3, "LootRoll", "Height", L["Frame Height"], true, {20, 50, 1}, updateLootRoll},
		{},
		{1, "Misc", "ExtTrainerUI", L["ExtTrainerUI"]},
		{1, "Misc", "TrainAll", L["TrainAll"], true, nil, nil, L["TrainAllTip"]},
		{1, "Misc", "ExtGuildUI", L["ExtGuildUI"], nil, nil, nil, L["ExtendedUITip"]},
		{1, "Misc", "ExtTalentUI", L["ExtTalentUI"], true, nil, nil, L["ExtendedUITip"]},
		{1, "Misc", "ExtVendorUI", L["ExtVendorUI"]},
		{1, "Misc", "ExtMacroUI", L["ExtMacroUI"], true, nil, nil ,L["ExtMacroUITip"]},
		{1, "Misc", "IconSearch", L["IconSearch"], nil, nil, nil, L["IconSearchGUITip"]},
		{1, "AFK", "Enable", L["AFK Mode"].."*", nil, nil, updateAFKMode},
		{3, "Misc", "FlightMapScale", L["FlightMap Scale"].."*", true, {1, 2, .1}, updateFlightMapScale},
		{1, "Misc", "FixMacroUI", L["FixMacroUI"], nil, nil, nil, L["ExtMacroUITip"]},
	},
}

local AddonSkins = {
	{"Ace3", "AceGUI-3.0"},
	{"alaCalendar", "alaCalendar"},
	{"alaGearMan", "alaGearMan"},
	{"AtlasLootClassic", "AtlasLootClassic"},
	{"Auctionator", "Auctionator"},
	{"AutoBar", "AutoBar"},
	{"ButtonForge", "Button Forge"},
	{"GearMenu", "GearMenu"},
	{"Immersion", "Immersion"},
	{"InboxMailBag", "Inbox MailBag"},
	{"ItemRack", "ItemRack"},
	{"Krowi_AchievementFilter", "Krowi_AchievementFilter"},
	{"ls_Toasts", "ls_Toasts"},
	{"MeetingHorn", "MeetingHorn"},
	{"MerInspect", "MerInspect"},
	{"ShadowDancer", "ShadowDancer"},
	{"Skillet", "Skillet"},
	{"Spy", "Spy"},
	{"tdAuction", "tdAuction"},
	{"tdInspect", "tdInspect"},
	{"ClassicThreatMeter", "ThreatClassic2"},
	{"WeakAurasOptions", "WeakAurasOptions"},
	{"WhisperPop", "WhisperPop"},
	{"WIM", "WIM"}
}

for i, value in ipairs(AddonSkins) do
	local key, name = unpack(value)
	tinsert(G.OptionList[5], 3 + i, {1, "Skins", key, name, (i % 2 == 0) and true})
end

function G.Variable(key, value, newValue)
	local header, charKey = strsplit(":", key)
	if header == "C" then
		if newValue ~= nil then
			NDuiPlusCharDB[charKey][value] = newValue
		else
			return NDuiPlusCharDB[charKey][value]
		end
	else
		if newValue ~= nil then
			NDuiPlusDB[key][value] = newValue
		else
			return NDuiPlusDB[key][value]
		end
	end
end

function G.GetDefaultSettings(key, value)
	local header, charKey = strsplit(":", key)
	if header == "C" then
		return P.CharacterSettings[charKey][value]
	else
		return P.DefaultSettings[key][value]
	end
end

local function SelectTab(i)
	for num = 1, #G.TabList do
		if num == i then
			guiTab[num]:SetBackdropColor(DB.r, DB.g, DB.b, .25)
			guiTab[num].checked = true
			guiPage[num]:Show()
		else
			guiTab[num]:SetBackdropColor(0, 0, 0, .25)
			guiTab[num].checked = false
			guiPage[num]:Hide()
		end
	end
end

local function tabOnClick(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	SelectTab(self.index)
end

local function tabOnEnter(self)
	if self.checked then return end
	self:SetBackdropColor(DB.r, DB.g, DB.b, .25)
end

local function tabOnLeave(self)
	if self.checked then return end
	self:SetBackdropColor(0, 0, 0, .25)
end

local function CreateTab(parent, i, name)
	local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
	tab:SetPoint("TOPLEFT", 10, -30*i - 20 + C.mult)
	tab:SetSize(90, 28)
	B.CreateBD(tab, .25)
	B.CreateFS(tab, 14, name, "system", "LEFT", 10, 0)
	tab.index = i

	tab:SetScript("OnClick", tabOnClick)
	tab:SetScript("OnEnter", tabOnEnter)
	tab:SetScript("OnLeave", tabOnLeave)

	return tab
end

local function CreateOption(i)
	local parent, offset = guiPage[i].child, 20

	for _, option in pairs(G.OptionList[i]) do
		local optType, key, value, name, horizon, data, callback, tooltip, scripts = unpack(option)
		-- Checkboxes
		if optType == 1 then
			local cb = B.CreateCheckBox(parent)
			cb:SetHitRectInsets(0, -80, 0, 0)
			if horizon then
				cb:SetPoint("TOPLEFT", 250, -offset + 35)
			else
				cb:SetPoint("TOPLEFT", 20, -offset)
				offset = offset + 35
			end
			cb.name = B.CreateFS(cb, 14, name, false, "LEFT", 30, 0)
			cb:SetChecked(G.Variable(key, value))
			cb:SetScript("OnClick", function()
				G.Variable(key, value, cb:GetChecked())
				if callback then callback() end
			end)
			if data and type(data) == "function" then
				local bu = B.CreateGear(parent)
				bu:SetPoint("LEFT", cb.name, "RIGHT", -2, 1)
				bu:SetScript("OnClick", data)
			end
			if tooltip then
				cb.title = L["Tips"]
				B.AddTooltip(cb, "ANCHOR_RIGHT", tooltip, "info")
			end
		-- Editbox
		elseif optType == 2 then
			local eb = B.CreateEditBox(parent, 180, 28)
			eb:SetMaxLetters(999)
			if horizon then
				eb:SetPoint("TOPLEFT", 255, -offset + 45)
			else
				eb:SetPoint("TOPLEFT", 25, -offset - 25)
				offset = offset + 70
			end
			eb:SetText(G.Variable(key, value))
			eb:HookScript("OnEscapePressed", function()
				eb:SetText(G.Variable(key, value))
			end)
			eb:HookScript("OnEnterPressed", function()
				G.Variable(key, value, eb:GetText())
				if callback then callback() end
			end)

			B.CreateFS(eb, 14, name, "system", "CENTER", 0, 25)
			eb.title = L["Tips"]
			local tip = L["EditBox Tip"]
			if tooltip then tip = tooltip.."|n"..tip end
			B.AddTooltip(eb, "ANCHOR_RIGHT", tip, "info")
		-- Slider
		elseif optType == 3 then
			local min, max, step = unpack(data)
			local x, y
			if horizon then
				x, y = 245, -offset + 40
			else
				x, y = 15, -offset - 30
				offset = offset + 70
			end
			local s = B.CreateSlider(parent, name, min, max, step, x, y)
			s.__default = G.GetDefaultSettings(key, value)
			s:SetValue(G.Variable(key, value))
			s:SetScript("OnValueChanged", function(_, v)
				local current = B:Round(tonumber(v), 2)
				G.Variable(key, value, current)
				s.value:SetText(current)
				if callback then callback() end
			end)
			s.value:SetText(B:Round(G.Variable(key, value), 2))
			if tooltip then
				s.title = L["Tips"]
				B.AddTooltip(s, "ANCHOR_RIGHT", tooltip, "info")
			end
		-- Dropdown
		elseif optType == 4 then
			if key == "TexStyle" then
				setupTexStyle()
				data = G.TextureList
			end

			local dd = B.CreateDropDown(parent, 180, 28, data)
			if horizon then
				dd:SetPoint("TOPLEFT", 255, -offset + 45)
			else
				dd:SetPoint("TOPLEFT", 25, -offset - 25)
				offset = offset + 70
			end
			dd.Text:SetText(data[G.Variable(key, value)])

			local opt = dd.options
			dd.button:HookScript("OnClick", function()
				for num = 1, #data do
					if num == G.Variable(key, value) then
						opt[num]:SetBackdropColor(1, .8, 0, .3)
						opt[num].selected = true
					else
						opt[num]:SetBackdropColor(0, 0, 0, .3)
						opt[num].selected = false
					end
				end
			end)
			for i in pairs(data) do
				opt[i]:HookScript("OnClick", function()
					G.Variable(key, value, i)
					if callback then callback() end
				end)
				if key == "TexStyle" then
					AddTextureToOption(opt, i) -- texture preview
				end
			end

			B.CreateFS(dd, 14, name, "system", "CENTER", 0, 25)
			if tooltip then
				dd.title = L["Tips"]
				B.AddTooltip(dd, "ANCHOR_RIGHT", tooltip, "info")
			end
			if key == "TexStyle" then
				local blank = CreateFrame("Frame", nil, dd.button.__list)
				blank:SetSize(20, 20)
				blank:SetPoint("TOPLEFT", dd.button.__list, "BOTTOMLEFT")
			end
		-- Colorswatch
		elseif optType == 5 then
			local swatch = B.CreateColorSwatch(parent, name, G.Variable(key, value))
			if horizon then
				swatch:SetPoint("TOPLEFT", 254, -offset + 30)
			else
				swatch:SetPoint("TOPLEFT", 24, -offset - 5)
				offset = offset + 35
			end
			swatch.__default = G.GetDefaultSettings(key, value)
		-- Button
		elseif optType == 6 then
			local bu = P.CreateButton(parent, 120, 24, name)
			if horizon then
				bu:SetPoint("TOPLEFT", 255, -offset + 35)
			else
				bu:SetPoint("TOPLEFT", 25, -offset)
				offset = offset + 35
			end
			bu:SetScript("OnClick", data)
		-- Blank, no optType
		else
			if not key then
				if optType and type(optType) == "string" then
					offset = offset + 10
					B.CreateFS(parent, 14, optType, nil, "TOP", 0, -offset + 8)
				end
				local line = B.SetGradient(parent, "H", 1, 1, 1, .25, .25, 420, C.mult)
				line:SetPoint("TOPLEFT", 20, -offset - 12)
			end
			offset = offset + 35
		end
		if scripts and type(scripts) == "table" then
			for type, handler in pairs(scripts) do
				parent:HookScript(type, handler)
			end
		end
	end

	local footer = CreateFrame("Frame", nil, parent)
	footer:SetSize(20, 20)
	footer:SetPoint("TOPLEFT", 25, -offset)
end

local function scrollBarHook(self, delta)
	local scrollBar = self.ScrollBar
	scrollBar:SetValue(scrollBar:GetValue() - delta*50)
end

function P:OpenGUI()
	if InCombatLockdown() then P:Error(ERR_NOT_IN_COMBAT) return end
	if gui then gui:Show() return end

	-- Main Frame
	gui = CreateFrame("Frame", "NDuiPlusGUI", UIParent)
	tinsert(UISpecialFrames, "NDuiPlusGUI")
	gui:SetSize(600, 480)
	gui:SetPoint("CENTER")
	gui:SetFrameStrata("HIGH")
	gui:SetFrameLevel(10)
	B.CreateMF(gui)
	B.SetBD(gui)
	B.CreateFS(gui, 18, "NDui_Plus", true, "TOP", 0, -10)
	B.CreateFS(gui, 16, format("v%s", P.Version), false, "TOP", 0, -30)

	local close = P.CreateButton(gui, 80, 20, CLOSE)
	close:SetPoint("BOTTOMRIGHT", -20, 15)
	close:SetScript("OnClick", function() gui:Hide() end)

	local ok = P.CreateButton(gui, 80, 20, OKAY)
	ok:SetPoint("RIGHT", close, "LEFT", -5, 0)
	ok:SetScript("OnClick", function()
		gui:Hide()
		StaticPopup_Show("RELOAD_NDUI")
	end)

	for i, name in pairs(G.TabList) do
		guiTab[i] = CreateTab(gui, i, name)

		guiPage[i] = CreateFrame("ScrollFrame", nil, gui, "UIPanelScrollFrameTemplate")
		guiPage[i]:SetPoint("TOPLEFT", 110, -50)
		guiPage[i]:SetPoint("BOTTOMRIGHT", -30, 50)
		B.CreateBDFrame(guiPage[i], .25)
		guiPage[i]:Hide()
		guiPage[i].child = CreateFrame("Frame", nil, guiPage[i])
		guiPage[i].child:SetSize(guiPage[i]:GetWidth(), 1)
		guiPage[i]:SetScrollChild(guiPage[i].child)
		B.ReskinScroll(guiPage[i].ScrollBar)
		guiPage[i]:SetScript("OnMouseWheel", scrollBarHook)

		CreateOption(i)
	end

	local helpInfo = B.CreateHelpInfo(gui)
	helpInfo:SetPoint("TOPRIGHT", -10, -5)
	helpInfo.title = L["Changelog"]
	B.AddTooltip(helpInfo, "ANCHOR_RIGHT", L["Option Tips"], "info")
	helpInfo:SetScript("OnClick", setupChangelog)

	local credit = CreateFrame("Button", nil, gui)
	credit:SetPoint("TOPRIGHT", -50, -5)
	credit:SetSize(40, 40)
	credit.Icon = credit:CreateTexture(nil, "ARTWORK")
	credit.Icon:SetAllPoints()
	credit.Icon:SetTexture(DB.creditTex)
	credit:SetHighlightTexture(DB.creditTex)
	credit.title = "Credits"
	B.AddTooltip(credit, "ANCHOR_RIGHT", "|n"..C_AddOns.GetAddOnMetadata(addonName, "X-Credits"), "info")

	local toggle = G.CreateToggleButton(gui)
	toggle:SetPoint("TOPLEFT", 25, -5)
	B.AddTooltip(toggle, "ANCHOR_RIGHT", "NDui", "info")
	toggle:SetScript("OnClick", function()
		if _G.GameMenuFrameNDui then
			_G.GameMenuFrameNDui:Click()
			gui:Hide()
		end
	end)

	if not NDuiPlusDB["Changelog"].Version or NDuiPlusDB["Changelog"].Version ~= P.Version then
		if DB.Client == "zhCN" then setupChangelog() end
		NDuiPlusDB["Changelog"].Version = P.Version
	end

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if gui:IsShown() then
				gui:Hide()
				B:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			gui:Show()
			B:UnregisterEvent(event, showLater)
		end
	end
	B:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)

	SelectTab(1)
end

function G:CreateToggleButton()
	local button = CreateFrame("Button", nil, self)
	button:SetPoint("TOPLEFT", 60, -5)
	button:SetSize(40, 40)
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints()
	button.Icon:SetTexture(P.SwapTex)
	button:SetHighlightTexture(P.SwapTex)

	return button
end

function G:SetupToggle()
	local NDuiGUI = _G.NDuiGUI
	if not NDuiGUI or G.ToggleButton then return end

	local toggle = G.CreateToggleButton(NDuiGUI)
	toggle:SetPoint("TOPLEFT", 60, -5)
	B.AddTooltip(toggle, "ANCHOR_RIGHT", "NDui_Plus", "info")
	toggle:SetScript("OnClick", function()
		P:OpenGUI()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
		NDuiGUI:Hide()
	end)
	G.ToggleButton = toggle
end

function G:OnLogin()
	local NDuiBtn = _G.GameMenuFrameNDui
	if not NDuiBtn then return end
	NDuiBtn:HookScript("PostClick",G.SetupToggle)
end

SlashCmdList["NDUI_PLUS"] = function(msg)
	local status = P:VersionCheck_Compare(DB.Version, P.SupportVersion)
	if status == "IsOld" then
		P:Print(format(L["Version Check"], P.SupportVersion))
		return
	end

	if msg:lower() == "debug" then
		NDuiPlusDB["Debug"] = not NDuiPlusDB["Debug"]
		_G.DEFAULT_CHAT_FRAME:AddMessage("|cFF70B8FFNDui_Plus:|r Debug " .. format(NDuiPlusDB["Debug"] and "on" or "off"))
	else
		P:OpenGUI()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end
end
SLASH_NDUI_PLUS1 = "/ndp"
SLASH_NDUI_PLUS2 = "/nduiplus"