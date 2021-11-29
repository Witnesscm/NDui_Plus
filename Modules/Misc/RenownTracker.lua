local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")
local T = P:GetModule("Tooltip")

local format = string.format

function M:AddRenownLevels()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(LANDING_PAGE_RENOWN_LABEL)
	GameTooltip:AddLine(" ")

	for index = 1, 4 do
		local level = NDuiPlusCharDB["RenownLevels"][index] or 0
		GameTooltip:AddDoubleLine(format("%s %s", T:GetCovenantIcon(index, 16), T:GetCovenantName(index)), level == 0 and "" or level, .6, .8, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

function M:UpdateRenownLevel()
	local covenantID = C_Covenants.GetActiveCovenantID()
	if covenantID and covenantID > 0 then
		NDuiPlusCharDB["RenownLevels"][covenantID] = C_CovenantSanctumUI.GetRenownLevel() or 0
	end
end

function M:HookRenownButton()
	local done
	hooksecurefunc(_G.GarrisonLandingPage, "SetupCovenantTopPanel", function(self)
		if done then return end

		local RenownButton = self.SoulbindPanel and self.SoulbindPanel.RenownButton
		if RenownButton then
			RenownButton:HookScript("OnEnter", M.AddRenownLevels)
			RenownButton:HookScript("OnLeave", B.HideTooltip)
		end

		done = true
	end)
end

P:AddCallbackForAddon("Blizzard_GarrisonUI", M.HookRenownButton)

function M:RenownTracker()
	M:UpdateRenownLevel()
	B:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED", function()
		P:Delay(1, M.UpdateRenownLevel)
	end)
end

M:RegisterMisc("RenownTracker", M.RenownTracker)