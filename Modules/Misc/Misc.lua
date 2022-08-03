local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:RegisterModule("Misc")

local _G = getfenv(0)
local format, select = string.format, select

M.MiscList = {}

function M:RegisterMisc(name, func)
	if not M.MiscList[name] then
		M.MiscList[name] = func
	end
end

function M:OnLogin()
	for name, func in next, M.MiscList do
		if name and type(func) == "function" then
			local _, catch = pcall(func)
			P:ThrowError(catch, format("%s Misc", name))
		end
	end
end

-- DoubleClick to swap specialization.
function M:DoubleClickSpecSwap()
	for i = 1, GetNumSpecializations() do
		local button = _G["PlayerTalentFrameSpecializationSpecButton"..i]
		button:HookScript("OnDoubleClick", function() 
			if i ~= GetSpecialization() then SetSpecialization(i) end
		end)

		button:HookScript("OnEnter", function() 
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(DB.LeftButton..L["QuickSpecSwap"], .6, .8, 1)
			GameTooltip:Show()
		end)
	end
end
P:AddCallbackForAddon("Blizzard_TalentUI", M.DoubleClickSpecSwap)

-- Auto collapse trade skill
local function collapseAllCategories(refresh)
	local list = _G.TradeSkillFrame.RecipeList
	if not list or not list:IsShown() then return end

	if not refresh and not M.db["AutoCollapse"] then return end

	list.tradeSkillChanged = nil
	list.collapsedCategories = {}

	if M.db["AutoCollapse"] then
		for _, categoryID in ipairs({C_TradeSkillUI.GetCategories()}) do
			list.collapsedCategories[categoryID] = true
		end
	end

	list:Refresh()
end

function M:AutoCollapseTradeSkill()
	local cb = CreateFrame("CheckButton", nil, _G.TradeSkillFrame, "OptionsCheckButtonTemplate")
	cb:SetHitRectInsets(-5, -5, -5, -5)
	cb:SetPoint("TOPRIGHT", -114, -2)
	cb:SetSize(24, 24)
	B.ReskinCheck(cb)
	cb.text = B.CreateFS(cb, 14, L["AutoCollapse"], false, "LEFT", 25, 0)
	cb:SetChecked(M.db["AutoCollapse"])
	cb:SetScript("OnClick", function(self)
		M.db["AutoCollapse"] = self:GetChecked()
		collapseAllCategories(true)
	end)

	hooksecurefunc(_G.TradeSkillFrame.RecipeList, "OnDataSourceChanged", function()
		collapseAllCategories()
	end)
end
P:AddCallbackForAddon("Blizzard_TradeSkillUI", M.AutoCollapseTradeSkill)

-- Learn all available skills. Credit: TrainAll
local function TrainAllButton_OnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format(L["Train All Cost"], self.Count, GetCoinTextureString(self.Cost)), 1, 1, 1)
	GameTooltip:Show()
end

function M:TrainAllSkills()
	local button = CreateFrame("Button", nil, ClassTrainerFrame, "MagicButtonTemplate")
	button:SetPoint("RIGHT", ClassTrainerTrainButton, "LEFT", -2, 0)
	button:SetText(L["Train All"])
	button.Count = 0
	button.Cost = 0
	ClassTrainerFrame.TrainAllButton = button

	button:SetScript("OnClick", function()
		for i = 1, GetNumTrainerServices() do
			if select(2, GetTrainerServiceInfo(i)) == "available" then
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
	end

	hooksecurefunc("ClassTrainerFrame_Update",function()
		local sum, total = 0, 0;
		for i = 1, GetNumTrainerServices() do
			if select(2, GetTrainerServiceInfo(i)) == "available" then
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

-- Autofill the Threads of Fate confirmation string
function M:ThreadsOfFateString()
	local fateDialog = StaticPopupDialogs["CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING"]
	if fateDialog and fateDialog.OnShow then
		hooksecurefunc(fateDialog, "OnShow", function(self)
			self.editBox:SetText(SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING)
		end)
	end
end
P:AddCallbackForAddon("Blizzard_PlayerChoice", M.ThreadsOfFateString)

-- Fix duplicate LFG applications after patch 9.1.5
do
	hooksecurefunc("LFGListUtil_SortSearchResults", function()
		local self = _G.LFGListFrame.SearchPanel
		if next(self.results) and next(self.applications) then
			for _, value in ipairs(self.applications) do
				tDeleteItem(self.results, value)
			end
			self.totalResults = #self.results
		end
	end)
end