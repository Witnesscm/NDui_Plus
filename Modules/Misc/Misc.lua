local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:RegisterModule("Misc")

local format = format

M.MiscList = {}

function M:RegisterMisc(name, func)
	if not M.MiscList[name] then
		M.MiscList[name] = func
	end
end

function M:OnLogin()
	for name, func in next, M.MiscList do
		xpcall(func, P.ThrowError)
	end
end

-- Add player name on TradeSkillFrame from Retail
do
	local function TradeSkill_UpdateTitle()
		local frame = _G.TradeSkillFrame
		if not frame.LinkNameButton then return end

		local linked, linkedName = IsTradeSkillLinked()
		if linked and linkedName then
			frame.LinkNameButton:Show()
			_G.TradeSkillFrameTitleText:SetFormattedText("%s %s[%s]|r", TRADE_SKILL_TITLE:format(GetTradeSkillLine()), HIGHLIGHT_FONT_COLOR_CODE, linkedName)
			frame.LinkNameButton.linkedName = linkedName
		else
			frame.LinkNameButton:Hide()
			frame.LinkNameButton.linkedName = nil
		end
	end

	function M:TradeSkill_AddName()
		local frame = _G.TradeSkillFrame
		if not frame.LinkNameButton then
			local button = CreateFrame("Button", nil, frame)
			button:SetAllPoints(_G.TradeSkillFrameTitleText)
			button:SetScript("OnClick", function(self)
				if self.linkedName then
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
					ChatFrame_OpenChat(SLASH_WHISPER1.." "..self.linkedName.." ", DEFAULT_CHAT_FRAME)
				end
			end)
			frame.LinkNameButton = button

			hooksecurefunc("TradeSkillFrame_Update", TradeSkill_UpdateTitle)
		end
	end

	P:AddCallbackForAddon("Blizzard_TradeSkillUI", M.TradeSkill_AddName)
end

-- Learn all available skills. Credit: TrainAll
do
	local function TrainAllButton_OnEnter(self)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(format(L["TrainAllCost"], self.Count, C_CurrencyInfo.GetCoinTextureString(self.Cost)), 1, 1, 1)
		GameTooltip:Show()
	end

	function M:TrainAllSkills()
		if not M.db["TrainAll"] then return end

		local button = CreateFrame("Button", nil, ClassTrainerFrame, "MagicButtonTemplate")
		button:SetPoint("RIGHT", ClassTrainerTrainButton, "LEFT", -2, 0)
		button:SetText(L["TrainAll"])
		button.Count = 0
		button.Cost = 0
		ClassTrainerFrame.TrainAllButton = button

		button:SetScript("OnClick", function()
			for i = 1, GetNumTrainerServices() do
				if select(3, GetTrainerServiceInfo(i)) == "available" then
					BuyTrainerService(i)
				end
			end
		end)

		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			self.UpdateTooltip = TrainAllButton_OnEnter
			TrainAllButton_OnEnter(self)
		end)

		button:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
			self.UpdateTooltip = nil
		end)

		if C.db["Skins"]["BlizzardSkins"] then
			B.Reskin(button)
			if button.LeftSeparator then button.LeftSeparator:SetAlpha(0) end
			if button.RightSeparator then button.RightSeparator:SetAlpha(0) end
		end

		hooksecurefunc("ClassTrainerFrame_Update",function()
			local sum, total = 0, 0
			for i = 1, GetNumTrainerServices() do
				if select(3, GetTrainerServiceInfo(i)) == "available" then
					sum = sum + 1
					total = total + GetTrainerServiceCost(i)
				end
			end

			button:SetEnabled(sum > 0)
			button.Count = sum
			button.Cost = total
		end)
	end

	P:AddCallbackForAddon("Blizzard_TrainerUI", M.TrainAllSkills)
end

do
	local titleString = "%a+ Attributes %- (.+)"

	local function hookTitleButton(frame)
		if frame.hooked then return end

		frame.TitleButton:HookScript("OnDoubleClick", function(self)
			local text = self.Text:GetText()
			local title = text and strmatch(text, titleString)
			if title then
				title = gsub(title, " %- ", ".")

				if ChatEdit_GetActiveWindow() then
					ChatEdit_InsertLink(title)
				else
					ChatFrame_OpenChat(title, SELECTED_DOCK_FRAME)
				end
			end
		end)

		frame.hooked = true
	end

	function M:Blizzard_TableInspector()
		hookTitleButton(_G.TableAttributeDisplay)
		hooksecurefunc(_G.TableInspectorMixin, "InspectTable", hookTitleButton)
	end

	P:AddCallbackForAddon("Blizzard_DebugTools", M.Blizzard_TableInspector)
end

-- Scale FlightMap
do
	function M:UpdateFlightMapScale()
		if not C.db["Skins"]["BlizzardSkins"] then return end

		local scale = M.db["FlightMapScale"]
		_G.TAXI_MAP_WIDTH = 316*scale
		_G.TAXI_MAP_HEIGHT = 352*scale
		_G.TaxiFrame:SetSize(384 + (scale - 1)*316, 512 + (scale - 1)*352)
		_G.TaxiMap:SetSize(_G.TAXI_MAP_WIDTH, _G.TAXI_MAP_HEIGHT)
		_G.TaxiRouteMap:SetSize(_G.TAXI_MAP_WIDTH, _G.TAXI_MAP_HEIGHT)
	end

	M:RegisterMisc("FlightMapScale", M.UpdateFlightMapScale)
end

-- DoubleClick to change talents
do
	local specs = {
		["spec1"] = 1,
		["spec2"] = 2
	}

	local function AddTips(self)
		if specs[self.specIndex] ~= GetActiveTalentGroup() then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(P.LeftButtonTip(L["QuickChangeTalents"]), .6, .8, 1)
			GameTooltip:Show()
		end
	end

	local function OnDoubleClick(self)
		local talentGroup = specs[self.specIndex]
		if talentGroup ~= GetActiveTalentGroup() then
			SetActiveTalentGroup(talentGroup)
		end
	end

	function M:QuickChangeTalents()
		_G.PlayerSpecTab1:SetScript("OnDoubleClick", OnDoubleClick)
		_G.PlayerSpecTab2:SetScript("OnDoubleClick", OnDoubleClick)
		hooksecurefunc("PlayerSpecTab_OnEnter", AddTips)
	end

	P:AddCallbackForAddon("Blizzard_TalentUI", M.QuickChangeTalents)
end