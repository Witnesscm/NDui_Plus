local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:RegisterModule("Misc")

local _G = getfenv(0)
local format, select = string.format, select

M.load = {}
M.preload = {}

function M:RegisterPreload(name, func)
	self.preload[name] = func or self[name]
end

function M:RegisterMisc(name, func)
	self.load[name] = func or self[name]
end

function M:OnInitialize()
	for name, func in next, self.preload do
		xpcall(func, P.ThrowError)
	end
end

function M:OnLogin()
	for name, func in next, self.load do
		xpcall(func, P.ThrowError)
	end
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
			local sum, total = 0, 0
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
end

-- Autofill the Threads of Fate confirmation string
do
	function M:ThreadsOfFateString()
		local fateDialog = StaticPopupDialogs["CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING"]
		if fateDialog and fateDialog.OnShow then
			hooksecurefunc(fateDialog, "OnShow", function(self)
				self.editBox:SetText(SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING)
			end)
		end
	end

	P:AddCallbackForAddon("Blizzard_PlayerChoice", M.ThreadsOfFateString)
end

do
	local titleString = "%a+ Attributes %- (.+)"

	local function hookTitleButton(frame)
		if frame.hooked then return end

		frame.TitleButton:HookScript("OnDoubleClick", function(self)
			local text = self.Text:GetText()
			local title = text and strmatch(text, titleString)
			if title then
				ChatFrame_OpenChat(gsub(title, " %- ", "."), SELECTED_DOCK_FRAME)
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

do
	local function resetPanelWidth()
		SetUIPanelAttribute(_G.ProfessionsFrame, "width", 0)
	end

	function M:ModifyProfessionsWidth()
		resetPanelWidth()
		_G.ProfessionsFrame.CraftingPage.CraftingOutputLog:HookScript("OnShow", resetPanelWidth)
		_G.ProfessionsFrame.CraftingPage.CraftingOutputLog:HookScript("OnHide", resetPanelWidth)
		_G.ProfessionsFrame.OrdersPage.OrderView.CraftingOutputLog:HookScript("OnShow", resetPanelWidth)
		_G.ProfessionsFrame.OrdersPage.OrderView.CraftingOutputLog:HookScript("OnHide", resetPanelWidth)
	end

	P:AddCallbackForAddon("Blizzard_Professions", M.ModifyProfessionsWidth)
end

-- remove <Right click for Frame Settings>
do
	function UnitFrame_UpdateTooltip(self)
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		if GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip) then
			self.UpdateTooltip = UnitFrame_UpdateTooltip
		else
			self.UpdateTooltip = nil
		end
	end
end
