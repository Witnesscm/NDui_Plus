local _, ns = ...
local B, C, L, DB, P = unpack(ns)
-----------------------
-- BetterWorldQuests
-- Author: p3lim
-----------------------
local MESSAGE = "Spam <SpaceBar> to complete!"
local BUTTON = "OverrideActionBarButton%d"

local locale = GetLocale()
if locale == "zhCN" or locale == "zhTW" then
	MESSAGE = "狂按 <空格> 完成!"
end

local quests = {
	[51632] = { -- Make Loh Go (Tiragarde Sound)
		[0] = {3, 2},
		[1] = {1, 2, 3, 2, 2},
		[2] = {1, 2, 1, 2, 2},
		[3] = {1, 2, 3, 2},
		[4] = {3, 2, 2, 2},
		[5] = {3, 2, 2},
		[6] = {3, 2, 1, 2, 2, 1, 2, 3, 2, 2},
	},
	[51633] = { -- Make Loh Go (Stormsong Valley)
		[0] = {3, 2},
		[1] = {1, 2, 3, 2, 2},
		[2] = {2, 1, 2, 2},
		[3] = {2, 2, 1, 2},
		[4] = {3, 2},
		[5] = {3, 2, 3, 2, 1, 2},
		[6] = {1, 2, 3, 2, 2},
		[7] = {3, 2, 1, 2, 2},
	},
	[51635] = { -- Make Loh Go (Vol"dun)
		[0] = {2, 3, 2, 3, 2, 1, 2, 1, 2},
		[1] = {1, 2, 3, 2},
		[2] = {1, 2},
		[3] = {2, 1, 2, 1, 2, 3, 2},
		[4] = {3, 2, 3, 2, 2, 2},
		[5] = {2, 2, 2, 2},
	},
	[51636] = { -- Make Loh Go (Zuldazar)
		[0] = {2, 2},
		[1] = {1, 2, 2, 1, 2},
		[2] = {2, 2},
		[3] = {1, 2, 2},
		[4] = {1, 2, 2, 2, 2},
		[5] = {2, 3, 2, 1, 2},
		[6] = {3, 2, 2},
		[7] = {2},
	},
}

local currentQuestID
local currentCheckpoint
local nextActionIndex

local actionSpells = {
	[271602] = true, -- 1: Turn Left
	[271600] = true, -- 2: Move Forward
	[271601] = true, -- 3: Turn Right
}

local Handler = CreateFrame("Frame")
Handler:RegisterEvent("QUEST_LOG_UPDATE")
Handler:RegisterEvent("QUEST_ACCEPTED")
Handler:SetScript("OnEvent", function(self, event, ...)
	if IsAddOnLoaded("BetterWorldQuests") then return end
	if not NDuiPlusDB["Misc"]["QuestHelper"] then return end

	if(event == "QUEST_LOG_UPDATE") then
		for questID in next, quests do
			if(C_QuestLog.IsOnQuest(questID)) then
				self:Watch(questID)
				if(self:GetCheckpoint() > 0) then
					self:Control()
					self:UpdateCheckpoint()
				end
				break
			end
		end

		self:UnregisterEvent(event)
	elseif(event == "QUEST_ACCEPTED") then
		local questID = ...
		if(quests[questID]) then
			self:Watch(questID)
		end
	elseif(event == "QUEST_REMOVED") then
		local questID = ...
		if(quests[questID]) then
			self:Unwatch()
		end
	elseif(event == "UNIT_ENTERED_VEHICLE") then
		self:Control()
	elseif(event == "UNIT_EXITED_VEHICLE") then
		self:Uncontrol()
	elseif(event == "UNIT_SPELLCAST_SUCCEEDED") then
		local _, _, spellID = ...
		if(actionSpells[spellID]) then
			self:UpdateAction()
		end
	elseif(event == "UNIT_AURA") then
		self:UpdateCheckpoint()
	end
end)

function Handler:Message()
	for i = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, MESSAGE, P.InfoColors)
	end
end

function Handler:Watch(questID)
	currentQuestID = questID
	currentCheckpoint = nil

	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("QUEST_REMOVED")
end

function Handler:Unwatch()
	currentQuestID = nil
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("QUEST_REMOVED")
end

function Handler:Control()
	self:Message()

	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterUnitEvent("UNIT_AURA", "vehicle")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "vehicle")
end

function Handler:Uncontrol()
	currentCheckpoint = nil

	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:UnregisterEvent("UNIT_AURA")

	ClearOverrideBindings(self)
end

function Handler:UpdateAction(_, _, spellID)
	ClearOverrideBindings(self)
	nextActionIndex = nextActionIndex + 1
	self:Next()
end

function Handler:GetCheckpoint()
	local checkpoint
	local index = 1
	while(true) do
		local exists, _, num, _, _, _, _, _, _, spellID = UnitAura("vehicle", index, "HARMFUL")
		if(not exists) then
			checkpoint = 0
			break
		elseif(spellID == 276705) then
			checkpoint = num
			break
		end

		index = index + 1
	end

	return checkpoint
end

function Handler:UpdateCheckpoint()
	local checkpoint = self:GetCheckpoint()
	if(checkpoint ~= currentCheckpoint) then
		currentCheckpoint = checkpoint
		nextActionIndex = 1

		self:Next()
	end
end

function Handler:Next()
	local nextAction = quests[currentQuestID][currentCheckpoint][nextActionIndex]
	SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(nextAction))
end