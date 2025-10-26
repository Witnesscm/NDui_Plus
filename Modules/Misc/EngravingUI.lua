local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

-- Sod Rune frame enhanced, inspired by https://wago.io/mwyLaQAlZ

local function RuneSpellButton_OnClick(self, button)
	if InCombatLockdown() then P:Error(ERR_NOT_IN_COMBAT) return end

	if button == "RightButton" then
		C_Engraving.CastRune(self.skillLineAbilityID)
	elseif not C_Engraving.IsRuneEquipped(self.skillLineAbilityID) then
		C_Engraving.CastRune(self.skillLineAbilityID)
		local rune = C_Engraving.GetCurrentRuneCast()
		if rune and rune.equipmentSlot then
			local slotID = rune.equipmentSlot == 16 and 15 or rune.equipmentSlot
			PickupInventoryItem(slotID)
			ClearCursor()
			local _, dialog = StaticPopup_Visible("REPLACE_ENCHANT")
			if dialog then
				dialog:GetButton1():Click()
			end
		end
	end
end

function M:EngravingUI_Update()
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

function M:EngravingUI_OnEquipmentChanged(slotID)
	if C_Engraving.IsEquipmentSlotEngravable(slotID) then
		M:EngravingUI_Update()
	end
end

local KnownRunes = {}

function M:EngravingUI_UpdateKnownRunes()
	C_Engraving.RefreshRunesList()
	local categories = C_Engraving.GetRuneCategories(false, true)
	for _, category in ipairs(categories) do
		local runes = C_Engraving.GetRunesForCategory(category, true)
		for _, info in ipairs(runes) do
			KnownRunes[info.skillLineAbilityID] = true
		end
	end
end

local function Collected_OnEnter(self)
	local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter()
	local known, max = C_Engraving.GetNumRunesKnown(exclusiveFilter)
	if known < max then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
		GameTooltip:AddLine(exclusiveFilter and format("%s %s", P.SlotIDtoName[exclusiveFilter], NOT_COLLECTED) or NOT_COLLECTED)

		local categories = exclusiveFilter and {exclusiveFilter} or C_Engraving.GetRuneCategories(false, false)
		for _, category in ipairs(categories) do
			local runes = C_Engraving.GetRunesForCategory(category, false)
			for _, info in ipairs(runes) do
				if not KnownRunes[info.skillLineAbilityID] then
					GameTooltip:AddLine(format("%s %s", P.TextureString(info.iconTexture, ":18:18:0:-2:64:64:5:59:5:59"), info.name), .6, .8, 1)
				end
			end
		end

		GameTooltip:Show()
	end
end

function M:EngravingUI_AddUncollectedTips()
	local parent = _G.EngravingFrame and _G.EngravingFrame.collected
	if not parent then return end

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOPLEFT")
	frame:SetPoint("BOTTOMLEFT")
	frame:SetWidth(100)
	frame:SetScript("OnEnter", Collected_OnEnter)
	frame:SetScript("OnLeave", B.HideTooltip)
end

function M:EngravingUI()
	if not M.db["EngravingUI"] or not C_Engraving.IsEngravingEnabled() then return end

	EngravingFrameSpell_OnClick = RuneSpellButton_OnClick
	hooksecurefunc("EngravingFrame_UpdateRuneList", M.EngravingUI_Update)
	B:RegisterEvent("RUNE_UPDATED", M.EngravingUI_Update)
	B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", M.EngravingUI_OnEquipmentChanged)

	-- Uncollected Runes
	M:EngravingUI_UpdateKnownRunes()
	B:RegisterEvent("NEW_RECIPE_LEARNED", M.EngravingUI_UpdateKnownRunes)
	M:EngravingUI_AddUncollectedTips()
end

P:AddCallbackForAddon("Blizzard_EngravingUI", M.EngravingUI)