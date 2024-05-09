local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local LAB = LibStub("LibActionButton-1.0-NDui", true) or LibStub("LibActionButton-1.0", true) -- pre-compatible
local ActionButtons = LAB.actionButtons

-- https://wago.tools/db2/Spell?build=4.4.0.54558&filter[Description_lang]=Finishing%20move%20that&page=1
local FinisherSpells = {
	["ROGUE"] = {
		[408] = true, -- 肾击
		[1943] = true, -- 割裂
		[2098] = true, -- 刺骨
		[5171] = true, -- 切割
		[8647] = true, -- 破甲
		[26679] = true, -- 致命投掷
		[32645] = true, -- 毒伤
		[73651] = true, -- 恢复
		[74860] = true, -- Ron's Test Eviscerate
		[82525] = true, -- Ron's Test Slice and Dice
	},
	["DRUID"] = {
		[1079] = true, -- 割裂(猎豹形态)
		[22568] = true, -- 凶猛撕咬(猎豹形态)
		[22570] = true, -- 割碎(猎豹形态)
		[24238] = true, -- Test Rip(等级 6)
		[52610] = true, -- 野蛮咆哮(猎豹形态)
		[62071] = true, -- 野蛮咆哮
	}
}

local function IsSpellOverlayed(spellId)
	if AB.Finishers[spellId] then
		return GetComboPoints("player", "target") == AB.MaxComboPoints
	end
	return false
end

function AB:UpdateMaxPoints(...)
	local unit, powerType = ...
	if not unit or (unit == "player" and powerType == "COMBO_POINTS") then
		AB.MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
	end
end

function AB:FinisherGlow_Update()
	local spellId = self:GetSpellId()
	if spellId and IsSpellOverlayed(spellId) then
		B.ShowOverlayGlow(self)
	else
		B.HideOverlayGlow(self)
	end
end

function AB:FinisherGlow_OnEvent(...)
	local unit, powerType = ...
	if not unit or (unit == "player" and powerType == "COMBO_POINTS") then
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
	B:RegisterEvent("PLAYER_TARGET_CHANGED", AB.FinisherGlow_OnEvent)
	LAB:RegisterCallback("OnButtonUpdate", AB.FinisherGlow_OnButtonUpdate)
end