local _, ns = ...
local B, C, L, DB, P = unpack(ns)
-----------------------
-- BetterWorldQuests
-- Author: p3lim
-----------------------
local BUTTON = "OverrideActionBarButton%d"

local actionMessages = {}
local actionResetSpells = {}
local spells = {
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
	[355677] = {
		[355834] = 1, -- 突刺
		[355835] = 2, -- 招架
		[355836] = 3, -- 还击
	},
}

local locale = GetLocale()
local MESSAGE = "Stand in circle and spam <SpaceBar> to complete!"
local trainerName = "Trainer Ikaros"
local nadjiaName = "Nadjia the Mistblade"

if locale == "deDE" then
	trainerName = "Ausbilder Ikaros"
elseif locale == "esES" or locale == "esMX" then
	trainerName = "Instructor Ikaros"
elseif locale == "frFR" then
	trainerName = "Instructeur Ikaros"
elseif locale == "itIT" then
	trainerName = "Istruttore Ikaros"
elseif locale == "koKR" then
	trainerName = "훈련사 이카로스"
elseif locale == "ptBR" then
	trainerName = "Treinador Ikaros"
elseif locale == "ruRU" then
	trainerName = "Укротитель Икар"
elseif locale == "zhCN" or locale == "zhTW" then
	MESSAGE = "站在圈里狂按 <空格> 完成!"
	trainerName = "训练师伊卡洛斯"
	nadjiaName = "娜德佳，迷雾之刃"
end

local questIDs = {
	[59585] = true,
	[64271] = true,
}

local questNPCs = {
	[trainerName] = true,
	[nadjiaName] = true,
}

local Handler = CreateFrame("Frame")
Handler:RegisterEvent("QUEST_LOG_UPDATE")
Handler:RegisterEvent("QUEST_ACCEPTED")
Handler:SetScript("OnEvent", function(self, event, ...)
	if IsAddOnLoaded("BetterWorldQuests") then return end
	if not NDuiPlusDB["Misc"]["QuestHelper"] then return end

	if event == "QUEST_LOG_UPDATE" then
		local found = false

		for questID in pairs(questIDs) do
			if C_QuestLog.IsOnQuest(questID) then
				found = true
				break
			end
		end

		if found then
			self:Watch()
		else
			self:Unwatch()
		end
	elseif event == "QUEST_ACCEPTED" then
		local questID = ...
		if questIDs[questID] then
			self:Watch()
		end
	elseif event == "QUEST_REMOVED" then
		local questID = ...
		if questIDs[questID] then
			self:Unwatch()
		end
	elseif event == "UNIT_AURA" then
		local found = false

		for buff, spellSet in next, spells do
			if GetPlayerAuraBySpellID(buff) then
				self:Control(spellSet)
				found = true
				return
			end
		end

		if not found then
			self:Uncontrol()
		end
	elseif event == "CHAT_MSG_MONSTER_SAY" then
		local msg, sender = ...
		if questNPCs[sender] then
			for spell, actionID in pairs (actionMessages) do
				if strmatch(msg, spell) then
					C_Timer.After(.2, function()
						-- wait a split second to get "Perfect"
						ClearOverrideBindings(self)
						SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(actionID))
					end)
					break
				end
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

function Handler:Watch()
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("QUEST_REMOVED")
end

function Handler:Unwatch()
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("QUEST_REMOVED")
	self:Uncontrol()
end

function Handler:Control(spellSet)
	if self.isControlling then return end

	table.wipe(actionMessages)
	table.wipe(actionResetSpells)
	for spellID, actionIndex in next, spellSet do
		actionMessages[(GetSpellInfo(spellID))] = actionIndex
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
		RaidNotice_AddMessage(RaidWarningFrame, MESSAGE, P.InfoColors)
	end
end
