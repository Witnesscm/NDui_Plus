local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:GetModule("Tooltip")

local USED_STRING = " |cffff0000("..USED..")|r"

local questItems = {
	[181443] = 61459,	-- 聚会通报官的聚会帽
	[184220] = 62821,	-- 罪碑碎片修复百科全书
	[187136] = 64367,	-- 研究报告-圣物检查技巧
	[190184] = 65623,	-- 无穷熏香
	[188793] = 65282,	-- 临时密文分析工具
}

function T:AlreadyUsed_CheckStatus()
	if not self.GetItem then return end

	local name = self:GetName()
	if not T.ItemTooltips[name] then return end

	local _, link = self:GetItem()
	if not link then return end

	local itemID = GetItemInfoFromHyperlink(link)
	local questID = itemID and questItems[itemID]

	if questID and C_QuestLog.IsQuestFlaggedCompleted(questID) then
		local line = _G[self:GetName().."TextLeft1"]
		local text = line and line:GetText()
		if text then
			line:SetText(text..USED_STRING)
			self:Show()
		end
	end
end

function T:AlreadyUsed()
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, T.AlreadyUsed_CheckStatus)
end