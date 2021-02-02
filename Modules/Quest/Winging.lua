local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local BUTTON = "ActionButton%d"
-----------------------
-- WQ: Just Winging It
-----------------------
local locale = GetLocale()
local msg1, msg2, msg3 = "安抚它", "抓紧了", "值得夸奖"
if locale == "enUS" then
	--msg1, msg2, msg3 = "", "", ""
elseif locale == "zhTW" then
	--msg1, msg2, msg3 = "", "", ""
end

local actionSpells = {
	[337835] = {
		index = 1,
		msg = msg1,
	},
	[337837] = {
		index = 2,
		msg = msg2,
		},
	[337842] = {
		index = 3,
		msg = msg3,
	},
}

local Handler = CreateFrame("Frame")
Handler:RegisterEvent("QUEST_LOG_UPDATE")
Handler:RegisterEvent("QUEST_ACCEPTED")
Handler:SetScript("OnEvent", function(self, event, ...)
	if not NDuiPlusDB["Misc"]["QuestHelper"] then return end

	if event == "QUEST_LOG_UPDATE" then
		if C_QuestLog.IsOnQuest(61540) then
			self:Watch()
		else
			self:Unwatch()
		end
	elseif event == "QUEST_ACCEPTED" then
		local questID = ...
		if questID == 61540 then
			self:Watch()
		end
	elseif(event == "QUEST_REMOVED") then
		local questID = ...
		if questID == 61540 then
			self:Unwatch()
		end
	elseif(event == "UNIT_ENTERED_VEHICLE") then
		self:Control()
	elseif(event == "UNIT_EXITED_VEHICLE") then
		self:Uncontrol()
	elseif event == "CHAT_MSG_RAID_BOSS_WHISPER" then
		local msg = ...
		for _, info in pairs (actionSpells) do
			if strmatch(msg, info.msg) then
				B.ShowOverlayGlow(_G[format(BUTTON, info.index)])
			end
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, spellID = ...
		if actionSpells[spellID] then
			for i = 1, 3 do
				B.HideOverlayGlow(_G[format(BUTTON, i)])
			end
		end
	end
end)

function Handler:Watch()
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("QUEST_REMOVED")
end

function Handler:Unwatch()
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("QUEST_REMOVED")
end

function Handler:Control()
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "vehicle")
end

function Handler:Uncontrol()
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
	self:UnregisterEvent("CHAT_MSG_RAID_BOSS_WHISPER")
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")

	for i = 1, 3 do
		B.HideOverlayGlow(_G[format(BUTTON, i)])
	end
end