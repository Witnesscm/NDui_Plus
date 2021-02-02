-----------------------
-- BetterWorldQuests
-- Author: p3lim
-----------------------
local HBD = LibStub('HereBeDragons-2.0')

local BASTION = 1533
local coordinateToHelper = {
	[169022] = {{0.5291, 0.4579}},
	[169023] = {{0.5306, 0.4750}},
	[169024] = {{0.5263, 0.4617}, {0.5258, 0.4660}},
	[169025] = {{0.5199, 0.4846}, {0.5265, 0.4744}},
	[169026] = {{0.5251, 0.4877}, {0.5182, 0.4540}},
	[169027] = {{0.5333, 0.4701}},
}

local function getClosestQuestNPC()
	local closestNPC
	local closestDistance = math.huge

	local pos = C_Map.GetPlayerMapPosition(BASTION, 'player')
	if not pos then
		return
	end

	local playerX, playerY = pos:GetXY()
	for npcID, data in next, coordinateToHelper do
		for _, coords in next, data do
			local distance = HBD:GetZoneDistance(BASTION, playerX, playerY, BASTION, coords[1], coords[2])
			if distance < closestDistance then
				closestNPC = npcID
				closestDistance = distance
			end
		end
	end

	return closestNPC
end

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('QUEST_LOG_UPDATE')
Handler:RegisterEvent('QUEST_ACCEPTED')
Handler:SetScript('OnEvent', function(self, event, ...)
	if IsAddOnLoaded("BetterWorldQuests") then return end
	if not NDuiPlusDB["Misc"]["QuestHelper"] then return end

	if event == 'QUEST_LOG_UPDATE' then
		if C_QuestLog.IsOnQuest(60565) then
			self:Watch()
		end
	elseif event == 'QUEST_ACCEPTED' then
		local _, questID = ...
		if questID == 60565 then
			self:Watch()
		end
	elseif event == 'QUEST_REMOVED' then
		local questID = ...
		if(questID == 60565) then
			self:Unwatch()
		end
	elseif event == 'UPDATE_MOUSEOVER_UNIT' then
		local unitGUID = UnitGUID('mouseover')
		if unitGUID then
			local closestQuestNPC = getClosestQuestNPC()
			if closestQuestNPC then
				local mouseNPC = tonumber((string.match(unitGUID, 'Creature%-.-%-.-%-.-%-.-%-(.-)%-')))
				if mouseNPC == closestQuestNPC and GetRaidTargetIndex('mouseover') ~= 4 then
					SetRaidTarget('mouseover', 4)
				end
			end
		end
	end
end)

function Handler:Watch()
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:RegisterEvent('QUEST_REMOVED')
end

function Handler:Unwatch()
	self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:UnregisterEvent('QUEST_REMOVED')
end
