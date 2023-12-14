local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local ActionButtons = {}

-- https://wago.tools/db2/Spell?filter[Description_lang]=%09Finishing%20move&build=1.15.0.52409&page=1
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
		[27615] = true, -- 肾击(等级 2)
		[31016] = true, -- 刺骨(等级 9)
		[398198] = true, -- 刀剑风暴
		[399963] = true, -- 毒伤
		[400009] = true, -- 正中眉心
		[400012] = true, -- 刃舞
	},
	["DRUID"] = {
		[1079] = true, -- 撕扯(等级 1)
		[9492] = true, -- 撕扯(等级 2)
		[9493] = true, -- 撕扯(等级 3)
		[9752] = true, -- 撕扯(等级 4)
		[9894] = true, -- 撕扯(等级 5)
		[9896] = true, -- 撕扯(等级 6)
		[22568] = true, -- 凶猛撕咬(等级 1)
		[22570] = true, -- 割碎(等级 1)
		[22827] = true, -- 凶猛撕咬(等级 2)
		[22828] = true, -- 凶猛撕咬(等级 3)
		[22829] = true, -- 凶猛撕咬(等级 4)
		-- [24238] = true,	-- Test Rip(Rank 6)
		-- [24248] = true,	-- Copy of Ferocious Bite(等级 4)
		[31018] = true, -- 凶猛撕咬(等级 5)
		[407988] = true, -- 野蛮咆哮
		[407989] = true, -- 野蛮咆哮
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
	local spellId
	local spellType, id = GetActionInfo(self.action)
	if spellType == "spell" then
		spellId = id
	elseif spellType == "macro" then
		spellId = GetMacroSpell(id)
	end

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

function AB:FinisherGlow_OnSlotChanged(slot)
	for button in next, ActionButtons do
		if button.action == slot then
			AB.FinisherGlow_Update(button)
			break
		end
	end
end

function AB:FinisherGlow_OnButtonUpdate()
	if not self.old_action or self.old_action ~= self.action then
		AB.FinisherGlow_Update(self)
		self.old_action = self.action
	end
end

function AB:FinisherGlow()
	if not AB.db["FinisherGlow"] then return end

	AB.Finishers = FinisherSpells[DB.MyClass]
	if not AB.Finishers then return end

	local Bar = B:GetModule("Actionbar")
	for _, button in ipairs(Bar.buttons) do
		if button.action then
			ActionButtons[button] = true
		end
	end

	AB:UpdateMaxPoints()
	B:RegisterEvent("UNIT_MAXPOWER", AB.UpdateMaxPoints)
	B:RegisterEvent("UNIT_POWER_UPDATE", AB.FinisherGlow_OnEvent)
	B:RegisterEvent("PLAYER_TARGET_CHANGED", AB.FinisherGlow_OnEvent)
	B:RegisterEvent("ACTIONBAR_SLOT_CHANGED", AB.FinisherGlow_OnSlotChanged)
	hooksecurefunc("ActionButton_Update", AB.FinisherGlow_OnButtonUpdate)
end