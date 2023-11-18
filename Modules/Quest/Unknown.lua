local _, ns = ...
local B, C, L, DB, P = unpack(ns)
-----------------------
-- BetterWorldQuests
-- Author: p3lim
-----------------------
local gormJuiceStage
local correctFairies = {
	[174770] = true,
	[174498] = true,
	[174771] = true,
	[174499] = true,
}

-- handles talking for the daily quest "Into the Unknown"
local Handler = CreateFrame("Frame")
Handler:RegisterEvent("GOSSIP_SHOW")
Handler:SetScript("OnEvent", function(self)
	if C_AddOns.IsAddOnLoaded("BetterWorldQuests") then return end
	if not NDuiPlusDB["Misc"]["QuestHelper"] then return end

	if IsShiftKeyDown() then return end

	local npcID = B.GetNPCID(UnitGUID("npc"))
	if npcID == 174365 then
		-- Guess the correct word in sentence, we always pick option 2 because it's easy, she
		-- will just keep asking for the correct one if you make a mistake
		if C_GossipInfo.GetNumOptions() == 1 then
			C_GossipInfo.SelectOption(1)
		else
			C_GossipInfo.SelectOption(2)
		end
	elseif npcID == 174371 then
		-- Mixy Mak, you ask her if the _can_ create something, then ask her to create it
		if not gormJuiceStage then
			C_GossipInfo.SelectOption(2)
		elseif gormJuiceStage == 1 then
			C_GossipInfo.SelectOption(C_GossipInfo.GetNumOptions())
		end

		gormJuiceStage = (gormJuiceStage or 0) + 1
	elseif correctFairies[npcID] then
		-- Guess the correct drunk faerie, they're all correct
		C_GossipInfo.SelectOption(3)
	end
end)
