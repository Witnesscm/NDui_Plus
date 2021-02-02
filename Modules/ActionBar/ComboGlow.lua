local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local AllGlowSpells = {
	["ROGUE"] = {
		[408] = true,
		[1943] = true,
		[2098] = true,
		[32645] = true,
		[121411] = true,
		[196819] = true,
		[269513] = true,
		[280719] = true,
		[315341] = true,
		[315496] = true,
		[319175] = true,
	},
	["DRUID"] = {
		[1079] = true,
		[22568] = true,
		[22570] = true,
		[52610] = true,
		[285381] = true,
	}
}

local function IsSpellOverlayed(spellId)
	if AB.GlowSpells[spellId] then
		return UnitPower("player", Enum.PowerType.ComboPoints) == AB.MaxComboPoints
	end
	return false
end

function AB:UpdateMaxCombo()
	AB.MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
end

function AB:UpdateOverlayGlow()
	local spellType, id = GetActionInfo(self.action)
	if spellType == "spell" and IsSpellOverlayed(id) then
		B.ShowOverlayGlow(self)
	elseif spellType == "macro" then
		local spellId = GetMacroSpell(id)
		if spellId and IsSpellOverlayed(spellId) then
			B.ShowOverlayGlow(self)
		else
			B.HideOverlayGlow(self)
		end
	else
		B.HideOverlayGlow(self)
	end
end

function AB:ActionBar_Update(event, ...)
	local button = self:GetParent()
	if event == "UNIT_POWER_UPDATE" then
		local unit, powerType = ...
		if unit == "player" and powerType == "COMBO_POINTS" then
			AB.UpdateOverlayGlow(button)
		end
	else
		C_Timer.After(.1, function()
			AB.UpdateOverlayGlow(button)
		end)
	end
end

function AB.CreateHandler(event)
	local Bar = B:GetModule("Actionbar")
	for _, button in ipairs(Bar.buttons) do
		if button.action then
			button.__handler = CreateFrame("Frame", nil, button)
			button.__handler:RegisterEvent("UNIT_POWER_UPDATE")
			button.__handler:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
			button.__handler:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
			button.__handler:SetScript("OnEvent", AB.ActionBar_Update)
		end
	end

	B:UnregisterEvent(event)
end

function AB:ComboGlow()
	if not NDuiPlusDB["ActionBar"]["ComboGlow"] then return end

	AB.GlowSpells = AllGlowSpells[DB.MyClass]
	if not AB.GlowSpells then return end

	AB:UpdateMaxCombo()
	B:RegisterEvent("UNIT_MAXPOWER", AB.UpdateMaxCombo)
	B:RegisterEvent("PLAYER_ENTERING_WORLD", AB.CreateHandler)
end