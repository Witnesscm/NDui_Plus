local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local LAB = LibStub("LibActionButton-1.0-NDui")
local ActionButtons = LAB.actionButtons

-- https://www.wowhead.com/cn/resource/4
local FinisherSpells = {
	["ROGUE"] = {
		[408] = true,		-- 肾击
		[1943] = true,		-- 割裂
		[2098] = true,		-- 斩击
		[32645] = true,		-- 毒伤
		[51690] = true,		-- 影舞步
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

function AB:UpdateMaxPoints(...)
	local unit, powerType = ...
	if not unit or (unit == "player" and powerType == "COMBO_POINTS") then
		AB.MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
	end
end

function AB:FinisherGlow_Update()
	local spellId = self:GetSpellId()
	if spellId and AB.Finishers[spellId] then
		if UnitPower("player", Enum.PowerType.ComboPoints) == AB.MaxComboPoints then
			B.ShowOverlayGlow(self)
		else
			B.HideOverlayGlow(self)
		end
	end
end

function AB:FinisherGlow_OnEvent(...)
	local unit, powerType = ...
	if unit == "player" and powerType == "COMBO_POINTS" then
		for button in next, ActionButtons do
			if button:IsVisible() then
				AB.FinisherGlow_Update(button)
			end
		end
	end
end

function AB:FinisherGlow_OnButtonUpdate(button)
	AB.FinisherGlow_Update(button)
end

function AB:FinisherGlow()
	if not AB.db["FinisherGlow"] then return end

	AB.Finishers = FinisherSpells[DB.MyClass]
	if not AB.Finishers then return end

	AB:UpdateMaxPoints()
	B:RegisterEvent("UNIT_MAXPOWER", AB.UpdateMaxPoints)
	B:RegisterEvent("UNIT_POWER_UPDATE", AB.FinisherGlow_OnEvent)
	LAB:RegisterCallback("OnButtonUpdate", AB.FinisherGlow_OnButtonUpdate)
end