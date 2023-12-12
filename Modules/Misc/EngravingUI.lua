local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

-- Sod Rune frame enhanced, inspired by https://wago.io/mwyLaQAlZ

local function RuneSpellButton_OnClick(self)
	if InCombatLockdown() then P:Error(ERR_NOT_IN_COMBAT) return end

	if not C_Engraving.IsRuneEquipped(self.skillLineAbilityID) then
		C_Engraving.CastRune(self.skillLineAbilityID)
		local rune = C_Engraving.GetCurrentRuneCast()
		if rune and rune.equipmentSlot then
			PickupInventoryItem(rune.equipmentSlot)
			ClearCursor()
			local _, dialog = StaticPopup_Visible("REPLACE_ENCHANT")
			if dialog then
				dialog.button1:Click()
			end
		end
	end
end

local function UpdateEquippedTextures()
	if not (_G.EngravingFrame and _G.EngravingFrame:IsVisible()) then return end

	local buttons = _G.EngravingFrame.scrollFrame.buttons
	for _, button in ipairs(buttons) do
		if not button.__equippedTex then
			button.__equippedTex = button:CreateTexture(nil, "BACKGROUND")
			button.__equippedTex:SetColorTexture(DB.r, DB.g, DB.b, .5)
			button.__equippedTex:SetInside()
		end

		if button:IsShown() and button.skillLineAbilityID then
			button.__equippedTex:SetShown(C_Engraving.IsRuneEquipped(button.skillLineAbilityID))
		end
	end
end

local function OnEquipmentChanged(_, slotID)
	if C_Engraving.IsEquipmentSlotEngravable(slotID) then
		UpdateEquippedTextures()
	end
end

function M:EngravingUI()
	if not C_Engraving.IsEngravingEnabled() then return end

	EngravingFrameSpell_OnClick = RuneSpellButton_OnClick
	hooksecurefunc("EngravingFrame_UpdateRuneList", UpdateEquippedTextures)
	B:RegisterEvent("RUNE_UPDATED", UpdateEquippedTextures)
	B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", OnEquipmentChanged)
end

P:AddCallbackForAddon("Blizzard_EngravingUI", M.EngravingUI)