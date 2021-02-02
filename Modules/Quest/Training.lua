-----------------------
-- BetterWorldQuests
-- Author: p3lim
-----------------------
local MESSAGE = 'Stand in circle and spam <SpaceBar> to complete!'
local BUTTON = 'OverrideActionBarButton%d'

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
}

local locale = GetLocale()
local trainerName = 'Trainer Ikaros'
if locale == 'deDE' then
	trainerName = 'Ausbilder Ikaros'
elseif locale == 'esES' or locale == 'esMX' then
	trainerName = 'Instructor Ikaros'
elseif locale == 'frFR' then
	trainerName = 'Instructeur Ikaros'
elseif locale == 'itIT' then
	trainerName = 'Istruttore Ikaros'
elseif locale == 'koKR' then
	trainerName = '훈련사 이카로스'
elseif locale == 'ptBR' then
	trainerName = 'Treinador Ikaros'
elseif locale == 'ruRU' then
	trainerName = 'Укротитель Икар'
elseif locale == 'zhCN' or locale == 'zhTW' then
	trainerName = '训练师伊卡洛斯'
	MESSAGE = '站在圈里狂按 <空格> 完成!'
end

local function GetNPCIDByGUID(guid)
	return guid and (tonumber((string.match(guid, 'Creature%-.-%-.-%-.-%-.-%-(.-)%-')) or ''))
end

local function auraFilter(a, _, _, _, _, _, _, _, _, _, _, _, b)
	return a == b
end

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('QUEST_LOG_UPDATE')
Handler:RegisterEvent('QUEST_ACCEPTED')
Handler:SetScript('OnEvent', function(self, event, ...)
	if IsAddOnLoaded("BetterWorldQuests") then return end
	if not NDuiPlusDB["Misc"]["QuestHelper"] then return end

	if event == 'QUEST_LOG_UPDATE' then
		if C_QuestLog.IsOnQuest(59585) then
			self:Watch()
		else
			self:Unwatch()
		end
	elseif event == 'QUEST_ACCEPTED' then
		local questID = ...
		if questID == 59585 then
			self:Watch()
		end
	elseif(event == 'QUEST_REMOVED') then
		local questID = ...
		if questID == 59585 then
			self:Unwatch()
		end
	elseif event == 'UNIT_AURA' then
		for buff, spellSet in next, spells do
			if AuraUtil.FindAura(auraFilter, 'player', 'HELPFUL', buff) then
				self:Control(spellSet)
				return
			else
				self:Uncontrol()
			end
		end
	elseif event == 'CHAT_MSG_MONSTER_SAY' then
		local msg, sender = ...
		if sender == trainerName then -- Trainer Ikaros
			for spell, actionID in pairs (actionMessages) do
				if strmatch(msg, spell) then
					C_Timer.After(0.5, function()
						-- wait a split second to get "Perfect"
						ClearOverrideBindings(self)
						SetOverrideBindingClick(self, true, 'SPACE', BUTTON:format(actionID))
					end)
					break
				end
			end
		end
	elseif event == 'UNIT_SPELLCAST_SUCCEEDED' then
		local _, _, spellID = ...
		if actionResetSpells[spellID] then
			ClearOverrideBindings(self)

			-- bind to something useless to avoid spamming jump
			SetOverrideBindingClick(self, true, 'SPACE', BUTTON:format(12))
		end
	elseif(event == 'PLAYER_REGEN_ENABLED') then
		ClearOverrideBindings(self)
		self:UnregisterEvent(event)
	end
end)

function Handler:Watch()
	self:RegisterUnitEvent('UNIT_AURA', 'player')
	self:RegisterEvent('QUEST_REMOVED')
end

function Handler:Unwatch()
	self:UnregisterEvent('UNIT_AURA')
	self:UnregisterEvent('QUEST_REMOVED')
	self:Uncontrol()
end

function Handler:Control(spellSet)
	table.wipe(actionMessages)
	table.wipe(actionResetSpells)
	for spellID, actionIndex in next, spellSet do
		actionMessages[(GetSpellInfo(spellID))] = actionIndex
		actionResetSpells[spellID] = true

		if spellID == 321844 then
			actionMessages["低扫"] = actionIndex -- zhCN fix
		end
	end

	-- bind to something useless to avoid spamming jump
	SetOverrideBindingClick(self, true, 'SPACE', BUTTON:format(12))

	self:Message()

	self:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
	self:RegisterEvent('CHAT_MSG_MONSTER_SAY')
end

function Handler:Uncontrol()
	self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	self:UnregisterEvent('CHAT_MSG_MONSTER_SAY')

	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		ClearOverrideBindings(self)
	end
end

function Handler:Message()
	for i = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, MESSAGE, ChatTypeInfo.RAID_WARNING)
	end
end
