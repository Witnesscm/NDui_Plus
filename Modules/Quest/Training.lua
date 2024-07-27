local _, ns = ...
local B, C, L, DB, P = unpack(ns)
-----------------------
-- BetterWorldQuests
-- Author: p3lim
-----------------------
local BUTTON = "OverrideActionBarButton%d"

local actionMessages = {}
local actionResetSpells = {}
local quests = {
	[59585] = { -- https://www.wowhead.com/quest=59585/well-make-an-aspirant-out-of-you
		trainer = L["Trainer Ikaros"],
		spells = {
			[321842] = {
				[321843] = 1, -- Strike
				[321844] = 2, -- Sweep
				[321847] = 3, -- Parry
			},
			[341925] = {
				[341931] = 1, -- Slash
				[341928] = 2, -- Bash
				[341929] = 3, -- Block
			},
			[341985] = {
				[342000] = 1, -- Jab
				[342001] = 2, -- Kick
				[342002] = 3, -- Dodge
			},
		}
	},
	[64271] = { -- https://www.wowhead.com/quest=64271/a-more-civilized-way
		trainer = L["Nadjia the Mistblade"],
		spells = {
			[355677] = {
				[355834] = 1, -- Lunge
				[355835] = 2, -- Parry
				[355836] = 3, -- Riposte
			},
		}
	},
}

local Handler = CreateFrame("Frame")
Handler:RegisterEvent("QUEST_LOG_UPDATE")
Handler:RegisterEvent("QUEST_ACCEPTED")
Handler:SetScript("OnEvent", function(self, event, ...)
	if C_AddOns.IsAddOnLoaded("BetterWorldQuests") then return end
	if not NDuiPlusDB["Misc"]["QuestHelper"] then return end

	if event == "QUEST_LOG_UPDATE" then
		for questID, questData in next, quests do
			if C_QuestLog.IsOnQuest(questID) then
				self:Watch(questData)
				return
			end
		end

		self:Unwatch()
	elseif event == "QUEST_ACCEPTED" then
		local questID = ...
		local questData = quests[questID]
		if questData then
			self:Watch(questData)
		end
	elseif event == "QUEST_REMOVED" then
		local questID = ...
		if quests[questID] then
			self:Unwatch()
		end
	elseif event == "UNIT_AURA" then
		for buff, spellSet in next, self.questData.spells do
			if GetPlayerAuraBySpellID(buff) then
				self:Control(spellSet)
				return
			end
		end

		self:Uncontrol()
	elseif event == "CHAT_MSG_MONSTER_SAY" then
		local msg, sender = ...
		if self.questData.trainer == sender then
			local actionID
			for actionName, actionIndex in next, actionMessages do
				if (msg:gsub("%.", "")):match(actionName) then
					actionID = actionIndex
				end
			end

			if actionID then
				C_Timer.After(.2, function()
					-- wait a split second to get "Perfect"
					ClearOverrideBindings(self)
					SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(actionID))
				end)
			end
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, spellID = ...
		if actionResetSpells[spellID] then
			ClearOverrideBindings(self)

			-- bind to something useless to avoid spamming jump
			SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(12))
		end
	elseif(event == "PLAYER_REGEN_ENABLED") then
		ClearOverrideBindings(self)
		self:UnregisterEvent(event)
	end
end)

function Handler:Watch(questData)
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("QUEST_REMOVED")

	self.questData = questData
end

function Handler:Unwatch()
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("QUEST_REMOVED")
	self:Uncontrol()

	self.questData = nil
end

function Handler:Control(spellSet)
	if self.isControlling then return end

	table.wipe(actionMessages)
	table.wipe(actionResetSpells)
	for spellID, actionIndex in next, spellSet do
		actionMessages[(C_Spell.GetSpellName(spellID))] = actionIndex
		actionResetSpells[spellID] = true

		-- zhCN fix
		if spellID == 321844 then
			actionMessages["低扫"] = actionIndex
		elseif spellID == 355834 then
			actionMessages["突袭"] = actionIndex
		end
	end

	-- bind to something useless to avoid spamming jump
	SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(12))

	self:Message()

	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY")

	self.isControlling = true
end

function Handler:Uncontrol()
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:UnregisterEvent("CHAT_MSG_MONSTER_SAY")

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		ClearOverrideBindings(self)
	end

	self.isControlling = false
end

function Handler:Message()
	for i = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, L["QuestHelperTip2"], P.InfoColors)
	end
end
