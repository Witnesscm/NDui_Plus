local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local PHASE_DIVING_AURA_ID = 1214374

function M.ExitPhaseDiving_Visibility(event, unit)
	if not unit or unit == "player" then
		local show = not not C_UnitAuras.GetPlayerAuraBySpellID(PHASE_DIVING_AURA_ID)
		if not InCombatLockdown() then
			M.ExitPhaseDivingButton:SetShown(show)
		else
			B:RegisterEvent("PLAYER_REGEN_ENABLED", M.ExitPhaseDiving_Visibility)
		end
	end

	if event == "PLAYER_REGEN_ENABLED" then
		B:UnregisterEvent("PLAYER_REGEN_ENABLED", M.ExitPhaseDiving_Visibility)
	end
end

local ZoneIds = {
	[2371] = true,
	[2472] = true
}

function M:ExitPhaseDiving_ZoneCheck()
	local mapID = C_Map.GetBestMapForUnit("player")
	if ZoneIds[mapID] then
		B:RegisterEvent("UNIT_AURA", M.ExitPhaseDiving_Visibility)
	else
		B:UnregisterEvent("UNIT_AURA", M.ExitPhaseDiving_Visibility)
	end
end

function M:ExitPhaseDiving_Toggle()
	if M.db["ExitPhaseDiving"] then
		M:ExitPhaseDiving_Visibility()
		M:ExitPhaseDiving_ZoneCheck()
		B:RegisterEvent("ZONE_CHANGED_NEW_AREA", M.ExitPhaseDiving_ZoneCheck)
	else
		M.ExitPhaseDivingButton:Hide()
		B:UnregisterEvent("UNIT_AURA", M.ExitPhaseDiving_Visibility)
		B:UnregisterEvent("ZONE_CHANGED_NEW_AREA", M.ExitPhaseDiving_ZoneCheck)
	end
end

function M:ExitPhaseDiving()
	local button = CreateFrame("Button", "NDuiPlus_ExitPhaseDivingButton", UIParent, "SecureActionButtonTemplate")
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", "/cancelaura " .. PHASE_DIVING_AURA_ID)
	button:SetAttribute("useOnKeyDown", false)
	button:RegisterForClicks("AnyUp", "AnyDown")
	button:SetSize(52, 52)
	B.AddTooltip(button, "ANCHOR_RIGHT", 1250255)

	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetTexture(4913234)
	button.Icon:SetInside()
	B.ReskinIcon(button.Icon, true)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .25)
	button.HL:SetInside()

	button:SetPushedTexture(DB.pushedTex)
	local push = button:GetPushedTexture()
	push:SetBlendMode("ADD")
	push:SetInside()

	button.mover = B.Mover(button, L["ExitPhaseDivingButton"], "ExitPhaseDivingButton", { "BOTTOM", UIParent, "BOTTOM", 250, 100 })

	M.ExitPhaseDivingButton = button
	M:ExitPhaseDiving_Toggle()
end

M:RegisterMisc("ExitPhaseDiving", M.ExitPhaseDiving)