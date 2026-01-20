local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local LAB = LibStub("LibActionButton-1.0-NDui", true)
local ActionButtons = LAB.actionButtons

-- https://wago.tools/db2/Spell?filter[Description_lang]=%09Finishing%20move&build=3.4.3.52237&page=1
local FinisherSpells = {
	["ROGUE"] = {
		[408] = true, -- 肾击(等级 1)
		[1943] = true, -- 割裂(等级 1)
		[2098] = true, -- 刺骨(等级 1)
		[5171] = true, -- 切割(等级 1)
		[6760] = true, -- 刺骨(等级 2)
		[6761] = true, -- 刺骨(等级 3)
		[6762] = true, -- 刺骨(等级 4)
		[6774] = true, -- 切割(等级 2)
		[8623] = true, -- 刺骨(等级 5)
		[8624] = true, -- 刺骨(等级 6)
		[8639] = true, -- 割裂(等级 2)
		[8640] = true, -- 割裂(等级 3)
		[8643] = true, -- 肾击(等级 2)
		[8647] = true, -- 破甲(等级 1)
		[8649] = true, -- 破甲(等级 2)
		[8650] = true, -- 破甲(等级 3)
		[11197] = true, -- 破甲(等级 4)
		[11198] = true, -- 破甲(等级 5)
		[11273] = true, -- 割裂(等级 4)
		[11274] = true, -- 割裂(等级 5)
		[11275] = true, -- 割裂(等级 6)
		[11299] = true, -- 刺骨(等级 7)
		[11300] = true, -- 刺骨(等级 8)
		[26679] = true, -- 致命投掷(等级 1)
		[26865] = true, -- 刺骨(等级 10)
		[26866] = true, -- 破甲(等级 6)
		[26867] = true, -- 割裂(等级 7)
		[31016] = true, -- 刺骨(等级 9)
		[32645] = true, -- 毒伤(等级 1)
		[32684] = true, -- 毒伤(等级 2)
		[48667] = true, -- 刺骨(等级 11)
		[48668] = true, -- 刺骨(等级 12)
		[48669] = true, -- 破甲(等级 7)
		[48671] = true, -- 割裂(等级 8)
		[48672] = true, -- 割裂(等级 9)
		[48673] = true, -- 致命投掷(等级 2)
		[48674] = true, -- 致命投掷(等级 3)
		[57992] = true, -- 毒伤(等级 3)
		[57993] = true -- 毒伤(等级 4)
	},
	["DRUID"] = {
		[1079] = true, -- 割裂(等级 1)
		[9492] = true, -- 割裂(等级 2)
		[9493] = true, -- 割裂(等级 3)
		[9752] = true, -- 割裂(等级 4)
		[9894] = true, -- 割裂(等级 5)
		[9896] = true, -- 割裂(等级 6)
		[22568] = true, -- 凶猛撕咬(等级 1)
		[22570] = true, -- 割碎(等级 1)
		[22827] = true, -- 凶猛撕咬(等级 2)
		[22828] = true, -- 凶猛撕咬(等级 3)
		[22829] = true, -- 凶猛撕咬(等级 4)
		-- [24238] = true, -- Test Rip(Rank 6)
		[24248] = true, -- 凶猛撕咬(等级 6)
		[27008] = true, -- 割裂(等级 7)
		[31018] = true, -- 凶猛撕咬(等级 5)
		[48576] = true, -- 凶猛撕咬(等级 7)
		[48577] = true, -- 凶猛撕咬(等级 8)
		[48628] = true, -- 锁喉(等级 1)
		[49799] = true, -- 割裂(等级 8)
		[49800] = true, -- 割裂(等级 9)
		[49802] = true, -- 割碎(等级 2)
		[52610] = true, -- 野蛮咆哮(等级 1)
		[62071] = true -- 野蛮咆哮
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