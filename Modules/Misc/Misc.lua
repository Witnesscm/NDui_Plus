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

-- One-click learning all dragonriding skills
do
	local rootNodeID = 64066 -- first skill

	local function Purchase(configID, nodeID)
		local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
		if nodeInfo then
			if not nodeInfo.meetsEdgeRequirements then return end

			if nodeInfo.type == Enum.TraitNodeType.Selection then
				C_Traits.SetSelection(configID, nodeID, nodeInfo.entryIDs[2]) -- choose second
			else
				if nodeInfo.ranksPurchased < nodeInfo.maxRanks then
					C_Traits.PurchaseRank(configID, nodeID)
				end
			end

			for _, edgeInfo in ipairs(nodeInfo.visibleEdges) do
				Purchase(configID, edgeInfo.targetNode)
			end
		end
	end

	local function OnClick(self)
		local treeID = self:GetParent():GetTalentTreeID()
		local configID = C_Traits.GetConfigIDByTreeID(treeID)
		Purchase(configID, rootNodeID)
		C_Traits.CommitConfig(configID)
	end

	function M:DragonridingTalent()
		local button = CreateFrame("Button", nil, _G.GenericTraitFrame, "MagicButtonTemplate")
		button:SetFrameStrata("HIGH")
		button:SetSize(120, 26)
		button:SetPoint("BOTTOMRIGHT", -75, 40)
		button:SetText(L["Learn All"])
		button:SetScript("OnClick", OnClick)
		GlowEmitterFactory:Show(button, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow)

		if C.db["Skins"]["BlizzardSkins"] then B.Reskin(button) end

		hooksecurefunc(_G.GenericTraitFrame.Currency, "Setup", function(_, info)
			button:SetShown((info and info.quantity or 0) > 0)
		end)
	end

	P:AddCallbackForAddon("Blizzard_GenericTraitUI", M.DragonridingTalent)
end