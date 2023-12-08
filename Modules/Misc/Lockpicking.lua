local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

-- 宝箱开锁等级
local LOCKPICKING = GetSpellInfo(1804)
local LOCKPICKING_MIN_SKILL = format("%%s|n%s", ITEM_MIN_SKILL)

local Lockboxes = {
	[16882] = 1,
	[4632] = 1,
	[6354] = 1,
	[6712] = 1,
	[4633] = 25,
	[16883] = 70,
	[4634] = 70,
	[6355] = 70,
	[4636] = 125,
	[4637] = 175,
	[13875] = 175,
	[16884] = 175,
	[4638] = 225,
	[5758] = 225,
	[5759] = 225,
	[5760] = 225,
	[16885] = 250,
	[13918] = 250,
	[12033] = 275,
	[29569] = 300,
	[31952] = 325,
	[43575] = 350,
	[43622] = 375,
	[43624] = 400,
	[45986] = 400,
}

local function AddSkillLevel(self)
	local link = select(2, self:GetItem())
	if link then
		local id = GetItemInfoFromHyperlink(link)
		local boxLevel = id and Lockboxes[id]
		if boxLevel then
			local line = _G[self:GetName().."TextLeft2"]
			local lineText = line and line:GetText()
			if lineText and lineText == LOCKED then
				line:SetFormattedText(LOCKPICKING_MIN_SKILL, lineText, LOCKPICKING, boxLevel)
			end
		end
	end
end

function M:Lockpicking()
	GameTooltip:HookScript("OnTooltipSetItem", AddSkillLevel)
	ItemRefTooltip:HookScript("OnTooltipSetItem", AddSkillLevel)
end

M:RegisterMisc("Lockpicking", M.Lockpicking)