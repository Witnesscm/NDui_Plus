local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local LAB = LibStub("LibActionButton-1.0")
local ActionButtons = LAB.actionButtons

-- https://www.wowhead.com/cn/resource/4
local AllGlowSpells = {
	["ROGUE"] = {
		[408] = true,		-- 肾击
		[1943] = true,		-- 割裂
		[2098] = true,		-- 斩击
		[32645] = true,		-- 毒伤
		[121411] = true,	-- 猩红风暴
		[196819] = true,	-- 刺骨
		[269513] = true,	-- 天降杀机
		[280719] = true,	-- 影分身
		[315341] = true,	-- 正中眉心
		[315496] = true,	-- 切割
		[319175] = true,	-- 黑火药
	},
	["DRUID"] = {
		[1079] = true,		-- 割裂
		[22568] = true,		-- 凶猛撕咬
		[22570] = true,		-- 割碎
		[52610] = true,		-- 野蛮咆哮
		[285381] = true,	-- 原始之怒
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

function AB:ComboGlow_Update()
	local spellId = self:GetSpellId()
	if spellId and IsSpellOverlayed(spellId) then
		B.ShowOverlayGlow(self)
	else
		B.HideOverlayGlow(self)
	end
end

function AB:ComboGlow_OnEvent( ...)
	local unit, powerType = ...
	if unit == "player" and powerType == "COMBO_POINTS" then
		for button in next, ActionButtons do
			AB.ComboGlow_Update(button)
		end
	end
end

function AB:ComboGlow_OnButtonUpdate(button)
	AB.ComboGlow_Update(button)
end

function AB:ComboGlow()
	if not AB.db["ComboGlow"] then return end

	AB.GlowSpells = AllGlowSpells[DB.MyClass]
	if not AB.GlowSpells then return end

	AB:UpdateMaxCombo()
	B:RegisterEvent("UNIT_MAXPOWER", AB.UpdateMaxCombo)
	B:RegisterEvent("UNIT_POWER_UPDATE", AB.ComboGlow_OnEvent)
	LAB:RegisterCallback("OnButtonUpdate", AB.ComboGlow_OnButtonUpdate)
end