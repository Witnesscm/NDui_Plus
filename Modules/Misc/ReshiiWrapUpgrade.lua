local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local WARPS_TREE_ID = 1115
local WARPS_ITEM_ID = 235499

local WrapsHelpInfo = {
	text = L["WrapsUpgradeTips"],
	buttonStyle = HelpTip.ButtonStyle.GotIt,
	targetPoint = HelpTip.Point.RightEdgeCenter,
	onAcknowledgeCallback = B.HelpInfoAcknowledge,
	callbackArg = "WrapsUpgrade",
}

function M:ReshiiWrapUpgrade()
	CharacterBackSlot:HookScript("OnMouseDown", function(self, button)
		if button == "MiddleButton" then
			local itemID = GetInventoryItemID("player", self:GetID())
			if itemID and itemID == WARPS_ITEM_ID then
				if not InCombatLockdown() then
					GenericTraitUI_LoadUI()
					GenericTraitFrame:SetTreeID(WARPS_TREE_ID)
					ShowUIPanel(GenericTraitFrame)
				else
					P:Error(ERR_NOT_IN_COMBAT)
				end
			end
		end
	end)

	hooksecurefunc(CharacterBackSlot, "SetAzeriteItem", function(self, itemLocation)
		if not itemLocation or not itemLocation:HasAnyLocation() then
			return
		end

		local itemID = C_Item.GetItemID(itemLocation)
		if itemID and itemID == WARPS_ITEM_ID then
			local configID = C_Traits.GetConfigIDByTreeID(WARPS_TREE_ID)
			local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, WARPS_TREE_ID, false)
			local currencyInfo = treeCurrencyInfo and treeCurrencyInfo[1]
			if currencyInfo and currencyInfo.quantity >= 3 then
				if not NDuiADB["Help"]["WrapsUpgrade"] then
					HelpTip:Show(self, WrapsHelpInfo)
				end

				self.AvailableTraitFrame:Show()
				self.AvailableTraitFrame.AvailableAnim:Play()
				self.AvailableTraitFrame.AvailableAnimGlow:Play()
			end
		end
	end)
end

M:RegisterMisc("ReshiiWrapUpgrade", M.ReshiiWrapUpgrade)
